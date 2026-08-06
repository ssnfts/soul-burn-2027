"""Talk to the Atlas bridge over a raw socket from inside Max.

Bypasses sLibAtlasBridgeCall so we can tell a genuine 'connection refused'
apart from a reply that never arrives (which would mean the job never ran).
"""
import json
import socket
import traceback

OUT = (r"C:\Users\mabdu\Downloads\SoulburnScriptsPack_3dsMax_v112_R2013toR2022"
       r"\SB2027\dev\ATLAS_SOCK.txt")

lines = []


def log(s):
    lines.append(str(s))
    print("[sock] %s" % s)


try:
    import atlas_max_bridge as b
    log("module file   : %s" % b.__file__)
    log("bridge running: %s" % b._BRIDGE.running)
    log("server socket : %s" % b._BRIDGE.server)
    log("serve thread  : %s alive=%s" % (
        b._BRIDGE.thread, b._BRIDGE.thread.is_alive() if b._BRIDGE.thread else None))
    log("host/port     : %s:%s" % (b._BRIDGE.host, b._BRIDGE.port))
except Exception:
    log("could not inspect bridge:\n" + traceback.format_exc())

for host in ("127.0.0.1", "localhost"):
    try:
        s = socket.create_connection((host, 9879), timeout=5)
        log("connected to %s:9879" % host)
        s.sendall(json.dumps({"cmd": "ping", "params": {}}).encode() + b"\n")
        s.settimeout(15)
        buf = b""
        while b"\n" not in buf:
            ch = s.recv(65536)
            if not ch:
                break
            buf += ch
        log("reply: %s" % buf.decode("utf-8", "replace").strip()[:400])
        s.close()
    except Exception as exc:
        log("connect %s failed: %s: %s" % (host, type(exc).__name__, exc))

with open(OUT, "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
