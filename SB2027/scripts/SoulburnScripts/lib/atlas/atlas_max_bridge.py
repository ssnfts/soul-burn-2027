"""
Atlas bridge core — runs *inside* 3ds Max.

Start it from the MAXScript listener (the one that opens by default):

    python.ExecuteFile @"<path-to-repo>\\bridge\\start_bridge.py"

Architecture — the DCC bridge pattern:

    socket thread -> queue -> pymxs.mxstoken() on the main thread -> pymxs -> result

The 3ds Max API is **main-thread only**. Calling pymxs from a socket handler
thread corrupts scene state or hard-crashes Max, and the crash lands minutes
later somewhere unrelated, so it is nearly impossible to attribute. Every job
enqueued by the socket thread is drained by a dotNet System.Windows.Forms.Timer
whose Tick is raised by the Windows message pump, so the drain always runs on
the main thread. No Qt/PySide6 dependency.

No PySide6 dependency: Max 2027 ships Python 3.13 whose PySide6 QtCore.pyd
cannot load against Max's own Qt6Core.dll, producing a DLL load failure.
``pymxs.mxstoken()`` is the correct replacement.

This module holds only the transport and lifecycle — the parts that own a bound
socket and rarely change. All command handling lives in ``atlas_max_handlers``,
which is hot-reloaded between requests when ATLAS_DEV_RELOAD=1 so handler edits
take effect without restarting the bridge or 3ds Max.
"""

from __future__ import annotations

import importlib
import json
import os
import queue
import socket
import sys
import threading
import traceback

try:
    import pymxs
except ImportError as _exc:  # pragma: no cover
    raise RuntimeError(
        "Atlas bridge must run inside 3ds Max (pymxs not importable)."
    ) from _exc

import atlas_max_handlers

# ── Configuration ─────────────────────────────────────────────────────────────

# 9876 is Houdini, 9877 ZBrush, 9878 Marvelous Designer on this machine.
HOST = "127.0.0.1"
PORT = int(os.environ.get("ATLAS_MAX_PORT", "9879"))

# Drain a bounded number of jobs per tick so a flood cannot freeze the UI.
JOBS_PER_TICK = 8
TICK_MS = 20

# Reload the handlers module before each job. On by default: handler edits are
# frequent during development, and the alternative is interrupting whoever is
# using Max to re-run the launcher after every change.
DEV_RELOAD = os.environ.get("ATLAS_DEV_RELOAD", "1") == "1"

ALLOW_MAXSCRIPT = atlas_max_handlers.ALLOW_MAXSCRIPT


class _Job:
    __slots__ = ("payload", "done", "result", "error", "traceback")

    def __init__(self, payload: dict):
        self.payload = payload
        self.done = threading.Event()
        self.result = None
        self.error: str | None = None
        self.traceback: str | None = None


class _Bridge:
    def __init__(self, host: str, port: int):
        self.host = host
        self.port = port
        self.queue: "queue.Queue[_Job]" = queue.Queue()
        self._ticker_installed: bool = False
        self.server: socket.socket | None = None
        self.thread: threading.Thread | None = None
        self.running = False

    # -- main thread --
    def _tick(self):
        for _ in range(JOBS_PER_TICK):
            try:
                job = self.queue.get_nowait()
            except queue.Empty:
                return

            try:
                handlers = atlas_max_handlers
                if DEV_RELOAD:
                    # Reload here, on the main thread, immediately before use.
                    # Reloading from the socket thread would race a job already
                    # executing against the previous module object.
                    handlers = importlib.reload(atlas_max_handlers)
                job.result = handlers.run_job(job.payload)
            except Exception as exc:
                job.error = f"{type(exc).__name__}: {exc}"
                job.traceback = traceback.format_exc()
            finally:
                job.done.set()

    # -- socket thread --
    def _serve(self):
        assert self.server is not None
        while self.running:
            try:
                conn, _addr = self.server.accept()
            except OSError:
                break  # listener closed
            threading.Thread(
                target=self._handle_connection, args=(conn,), daemon=True
            ).start()

    def _handle_connection(self, conn: socket.socket):
        # Per-command connections: these bridges are low-throughput, and a
        # dropped socket then cannot wedge the session.
        with conn:
            try:
                conn.settimeout(1800.0)
                buf = b""
                while b"\n" not in buf:
                    chunk = conn.recv(65536)
                    if not chunk:
                        return
                    buf += chunk
                    if len(buf) > 64 * 1024 * 1024:
                        raise ValueError("request exceeded 64 MB")

                payload = json.loads(buf.partition(b"\n")[0].decode("utf-8"))

                # Execute here, on this connection thread, guarded by
                # pymxs.mxstoken() -- Autodesk's documented way to call pymxs
                # from a non-main thread.
                #
                # This used to enqueue the job for a main-thread pump. 3ds Max
                # has no periodic general callback to drive such a pump
                # (#tickCallback is not a real callback type), so every job sat
                # in the queue until the caller timed out and the bridge looked
                # dead. Running inline under mxstoken is what actually works.
                try:
                    handlers = atlas_max_handlers
                    if DEV_RELOAD:
                        handlers = importlib.reload(atlas_max_handlers)
                    token = getattr(pymxs, "mxstoken", None)
                    if token is not None:
                        with token():
                            result = handlers.run_job(payload)
                    else:
                        result = handlers.run_job(payload)
                    response = {"ok": True, "result": result}
                except Exception as exc:
                    response = {
                        "ok": False,
                        "error": f"{type(exc).__name__}: {exc}",
                        "traceback": traceback.format_exc(),
                    }

            except Exception as exc:
                response = {
                    "ok": False,
                    "error": f"{type(exc).__name__}: {exc}",
                    "traceback": traceback.format_exc(),
                }

            try:
                conn.sendall(json.dumps(response, default=str).encode("utf-8") + b"\n")
            except OSError:
                pass

    # -- lifecycle --
    def start(self):
        if self.running:
            print(f"[atlas] bridge already running on {self.host}:{self.port}")
            return

        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            # Loopback only: this socket accepts code for execution inside the
            # host and must never be reachable off-machine.
            srv.bind((self.host, self.port))
        except OSError as exc:
            srv.close()
            raise RuntimeError(
                f"cannot bind {self.host}:{self.port} ({exc}). Another DCC bridge "
                f"may hold it — 9876 Houdini, 9877 ZBrush, 9878 Marvelous "
                f"Designer. Set ATLAS_MAX_PORT to choose another."
            ) from exc
        srv.listen(8)

        self.server = srv
        self.running = True

        # Drain the job queue on the MAIN thread at ~30 fps.
        #
        # This used callbacks.addScript(#tickCallback, ...), but #tickCallback is
        # not a real 3ds Max general-callback type -- callbacks.addScript only
        # accepts scene/system events (#filePostOpen, #selectionSetChanged, ...),
        # so start() died with:
        #     callbacks.addScript() unrecognized callback type: #tickCallback
        # There is no periodic callback in that system at all.
        #
        # A dotNet System.Windows.Forms.Timer is the supported way to get a
        # periodic tick on Max's UI thread: its Tick is raised by the Windows
        # message pump, so the handler is already on the main thread and pymxs
        # is safe to call. No Qt, no PySide6.
        # NOTE: MaxScript's execute() evaluates the string as ONE expression, so
        # a multi-statement block must be wrapped in parentheses or only the
        # first statement runs -- which is why the timer silently never existed.
        # Keep this as a single parenthesised block, unindented.
        pymxs.runtime.execute(
            '(\n'
            'global _atlasBridgeTimer\n'
            'global _atlasBridgeTick\n'
            'if _atlasBridgeTimer != undefined do (try (_atlasBridgeTimer.Stop()) catch ())\n'
            # the handler must stay referenced by a global or .NET collects it
            'fn _atlasBridgeTick sender args = '
            '(try (python.Execute "import atlas_max_bridge as _b; _b._BRIDGE._tick()") catch ())\n'
            '_atlasBridgeTimer = dotNetObject "System.Windows.Forms.Timer"\n'
            '_atlasBridgeTimer.Interval = 33\n'
            'dotNet.addEventHandler _atlasBridgeTimer "Tick" _atlasBridgeTick\n'
            '_atlasBridgeTimer.Start()\n'
            'true\n'
            ')'
        )
        # The timer is now only a convenience for anything that still enqueues
        # onto self.queue; jobs from the socket run inline under mxstoken, so a
        # failed timer must NOT stop the bridge.
        try:
            running = pymxs.runtime.execute(
                '(if _atlasBridgeTimer == undefined then false else _atlasBridgeTimer.Enabled)'
            )
        except Exception:
            running = False
        self._ticker_installed = bool(running)
        if not running:
            print("[atlas] note: main-thread tick timer unavailable; "
                  "jobs run inline under pymxs.mxstoken()")

        self.thread = threading.Thread(target=self._serve, daemon=True)
        self.thread.start()

        print(f"[atlas] bridge listening on {self.host}:{self.port}")
        print(f"[atlas] raw MaxScript : {'ENABLED' if ALLOW_MAXSCRIPT else 'disabled'}")
        print(f"[atlas] handler reload: {'on' if DEV_RELOAD else 'off'}")

    def stop(self):
        self.running = False
        if self._ticker_installed:
            pymxs.runtime.execute(
                '(if _atlasBridgeTimer != undefined do '
                '(try (_atlasBridgeTimer.Stop()) catch (); _atlasBridgeTimer = undefined))'
            )
            self._ticker_installed = False
        if self.server is not None:
            try:
                self.server.close()
            except OSError:
                pass
            self.server = None
        print("[atlas] bridge stopped")


_BRIDGE = _Bridge(HOST, PORT)


def start():
    """Start the bridge. Must be called from the 3ds Max main thread."""
    _BRIDGE.start()


def stop():
    """Stop the bridge."""
    _BRIDGE.stop()


if __name__ == "__main__":
    start()
