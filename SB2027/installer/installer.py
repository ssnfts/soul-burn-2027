"""
SoulBurn Scripts Pack v2.0 — Windows Installer
installer.py

Detects installed 3ds Max versions (2020-2027) via registry + filesystem,
shows a GUI wizard, copies files to correct per-version user paths.

Build to EXE: python build_installer.py build_exe
"""

import os
import sys
import shutil
import json
import winreg
import subprocess
import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import threading

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

PRODUCT_NAME = "SoulBurn Scripts Pack"
VERSION = "v2.0"
BANNER = f"{PRODUCT_NAME} {VERSION} for 3ds Max"

# Max major version → product year mapping
MAX_VERSION_MAP = {
    22: 2020, 23: 2021, 24: 2022,
    25: 2023, 26: 2024, 27: 2025,
    28: 2026, 29: 2027,
}

# PySide6 is EXCLUDED — Max 2027 ships its own PySide6 6.8.3 built against its
# own Qt DLLs. pip install PySide6 installs a DIFFERENT Qt build (6.11.x) into
# Roaming\Python313\site-packages which shadows Max's version and causes:
#   "DLL load failed while importing QtCore: The specified procedure could not be found"
# Never install PySide6 via pip when targeting Max's embedded Python.
PYTHON_DEPS = ["fastmcp", "pandas", "shapely"]

# ---------------------------------------------------------------------------
# Source root resolution — works both frozen (EXE) and plain (.py)
# ---------------------------------------------------------------------------
# When cx_Freeze builds the EXE it places the frozen bytecode under
#   <dist>\lib\
# and copies data files to
#   <dist>\scripts\, <dist>\MacroScripts\, <dist>\UI_ln\, ...
#
# sys.frozen is set by cx_Freeze.  sys.executable is the EXE path.
# __file__ inside a frozen module resolves to the lib\ sub-directory,
# so os.path.dirname(__file__) would give us <dist>\lib\ — one level
# too deep — and we would never find the data.
#
# The fix: when frozen, SOURCE_ROOT is the *directory containing the EXE*
# (i.e. the dist folder itself).  When running as a plain .py file,
# SOURCE_ROOT is the parent of the installer/ directory, exactly as before.

if getattr(sys, "frozen", False):
    # Running as a compiled EXE produced by cx_Freeze
    SOURCE_ROOT = os.path.dirname(os.path.abspath(sys.executable))
else:
    # Running as a plain .py script
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    SOURCE_ROOT = os.path.dirname(_SCRIPT_DIR)   # parent of installer/

# Install mapping: (source_rel, dest_rel_to_enu)
#
# .mcr files MUST go to usermacros\ — that is the folder listed under
# "Additional Macros" in 3dsMax.ini and the only user-writable location
# Max scans at startup to populate Customize > Toolbars categories.
#
# scripts\startup\ is for .ms startup scripts (not macros).
# Confirmed by inspecting 3dsMax.ini "Additional Macros=" line and by
# the fact that tyFlow installs its .mcr files to usermacros\.
INSTALL_MAP = [
    ("scripts/SoulburnScripts",                          "scripts/SoulburnScripts"),
    ("scripts/Startup/SoulburnScripts_AtlasAutoStart.ms","scripts/startup/SoulburnScripts_AtlasAutoStart.ms"),
    ("scripts/Startup/SoulburnScripts_ToolbarAutoCreate.ms","scripts/startup/SoulburnScripts_ToolbarAutoCreate.ms"),
    ("MacroScripts/SoulburnScripts.mcr",                 "usermacros/SoulburnScripts.mcr"),
    ("MacroScripts/SoulburnScriptsExtras.mcr",           "usermacros/SoulburnScriptsExtras.mcr"),
    # CUIX toolbar definition -- primary: en-US/plugcfg/SoulburnScripts/ (where #plugcfg resolves on Max 2027)
    # This is the same location ChaosScatter and other plugins use.
    ("MacroScripts/SoulburnScripts.cuix",                "en-US/plugcfg/SoulburnScripts/SoulburnScripts.cuix"),
    # CUIX toolbar definition -- secondary: UI_ln/ (used by cui.loadConfig fallback in startup script)
    ("MacroScripts/SoulburnScripts.cuix",                "UI_ln/SoulburnScripts.cuix"),
    ("UI_ln/Icons",                                       "UI_ln/Icons"),
    ("UI_ln/IconsDark",                                   "UI_ln/IconsDark"),
]


def is_already_installed(enu_path) -> tuple[bool, str]:
    checks = [
        os.path.join(enu_path, "usermacros", "SoulburnScripts.mcr"),
        os.path.join(enu_path, "scripts", "SoulburnScripts"),
        os.path.join(enu_path, "UI_ln", "Icons"),
    ]
    missing = [c for c in checks if not os.path.exists(c)]
    if not missing:
        return True, "Already installed"
    if len(missing) < len(checks):
        return False, f"Partial install ({len(checks)-len(missing)}/{len(checks)} components)"
    return False, "Not yet installed"

# ---------------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------------

def detect_max_versions():
    """Return list of dicts for each detected Max installation."""
    found = []
    localappdata = os.environ.get("LOCALAPPDATA", "")

    for major, year in MAX_VERSION_MAP.items():
        info = {
            "year": year,
            "major": major,
            "enu_path": None,
            "install_dir": None,
            "python_exe": None,
            "detected": False,
        }

        # 1) Registry
        try:
            reg_path = fr"SOFTWARE\Autodesk\3dsMax\{major}.0"
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path) as key:
                install_dir, _ = winreg.QueryValueEx(key, "InstallDir")
                info["install_dir"] = install_dir
                py_exe = os.path.join(install_dir, "Python", "python.exe")
                if os.path.exists(py_exe):
                    info["python_exe"] = py_exe
                info["detected"] = True
        except (FileNotFoundError, OSError, WindowsError):
            pass

        # 2) Filesystem fallback
        enu = os.path.join(localappdata, "Autodesk", "3dsMax",
                           f"{year} - 64bit", "ENU")
        if os.path.isdir(enu) or info["detected"]:
            info["enu_path"] = enu
            info["detected"] = True

        if info["detected"]:
            found.append(info)

    return found


# ---------------------------------------------------------------------------
# Installation
# ---------------------------------------------------------------------------

def copy_tree(src, dst, progress_cb=None):
    """Recursively copy src to dst, calling progress_cb(path) for each file."""
    os.makedirs(os.path.dirname(dst) if os.path.isfile(src) else dst, exist_ok=True)
    if os.path.isfile(src):
        shutil.copy2(src, dst)
        if progress_cb:
            progress_cb(dst)
    else:
        shutil.copytree(src, dst, dirs_exist_ok=True,
                        copy_function=lambda s, d: (shutil.copy2(s, d),
                                                    progress_cb(d) if progress_cb else None))


def install_to_version(version_info, options, progress_cb=None, log_cb=None):
    """Install SoulBurn to one Max version. Returns list of installed files."""
    enu = version_info["enu_path"]
    if not enu:
        if log_cb:
            log_cb(f"SKIP {version_info['year']}: no ENU path found")
        return []

    os.makedirs(enu, exist_ok=True)
    installed_files = []

    # Optional backup
    if options.get("backup"):
        sb_dir = os.path.join(enu, "scripts", "SoulburnScripts")
        if os.path.isdir(sb_dir):
            backup_dir = sb_dir + "_backup"
            if log_cb:
                log_cb(f"Backing up {sb_dir} → {backup_dir}")
            if os.path.isdir(backup_dir):
                shutil.rmtree(backup_dir)
            shutil.copytree(sb_dir, backup_dir)

    for src_rel, dst_rel in INSTALL_MAP:
        src = os.path.join(SOURCE_ROOT, src_rel.replace("/", os.sep))
        dst = os.path.join(enu, dst_rel.replace("/", os.sep))
        if not os.path.exists(src):
            if log_cb:
                log_cb(f"  SKIP (not found): {src}")
            continue

        # NOTE: the closure must capture `enu` by value via a default
        # argument — otherwise all iterations share the same `enu`
        # reference and the last value wins (classic late-binding bug).
        def _make_cb(enu_path):
            def _cb(path):
                installed_files.append(path)
                rel = os.path.relpath(path, enu_path)
                if log_cb:
                    log_cb(f"  OK {rel}")
                if progress_cb:
                    progress_cb(rel)
            return _cb

        copy_tree(src, dst, _make_cb(enu))

    # Write AtlasAutoStart preference if requested
    if options.get("autostart"):
        plugcfg_dir = os.path.join(enu, "plugcfg", "SoulburnScripts")
        os.makedirs(plugcfg_dir, exist_ok=True)
        autostart_ini = os.path.join(plugcfg_dir, "AtlasAutoStart.ini")
        with open(autostart_ini, "w") as _f:
            _f.write("[AtlasAutoStart]\nenabled=true\n")
        if log_cb:
            log_cb("  OK AtlasAutoStart.ini written (enabled=true)")
        installed_files.append(autostart_ini)

    # Write uninstall manifest
    manifest_path = os.path.join(enu, "scripts", "SoulburnScripts",
                                  "uninstall_manifest.json")
    with open(manifest_path, "w") as f:
        json.dump(installed_files, f, indent=2)

    # Write uninstall registry entry
    try:
        key_path = (r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
                    rf"\SoulburnScripts_{version_info['year']}")
        with winreg.CreateKey(winreg.HKEY_CURRENT_USER, key_path) as key:
            winreg.SetValueEx(key, "DisplayName", 0, winreg.REG_SZ,
                              f"SoulBurn Scripts v2.0 (3ds Max {version_info['year']})")
            winreg.SetValueEx(key, "DisplayVersion", 0, winreg.REG_SZ, "2.0")
            winreg.SetValueEx(key, "Publisher", 0, winreg.REG_SZ, "SoulBurn 2027")
            winreg.SetValueEx(key, "UninstallManifest", 0, winreg.REG_SZ, manifest_path)
    except Exception:
        pass

    return installed_files


def run_pip(python_exe, packages, log_cb=None):
    """
    Install Python packages into Max's embedded Python.

    Max 2027's embedded Python ships without pip. We bootstrap it first
    using the stdlib ensurepip module (always present), then upgrade pip,
    then install the requested packages. Each stage is logged individually
    so a failure is immediately obvious.
    """
    if not python_exe or not os.path.exists(python_exe):
        if log_cb:
            log_cb("  SKIP pip: python.exe not found at " + str(python_exe))
        return

    def _run(cmd, label):
        """Run one subprocess command, stream its output, return exit code."""
        if log_cb:
            log_cb(f"  Running: {' '.join(cmd)}")
        try:
            proc = subprocess.Popen(
                cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                text=True, errors="replace"
            )
            for line in proc.stdout:
                if log_cb:
                    log_cb("    " + line.rstrip())
            proc.wait()
            return proc.returncode
        except Exception as exc:
            if log_cb:
                log_cb(f"  FAIL {label}: {exc}")
            return -1

    # ── Stage 1: bootstrap pip if missing ────────────────────────────────────
    # Test first — avoid the slow ensurepip call on machines that already have it.
    test_rc = _run([python_exe, "-m", "pip", "--version"], "pip version check")
    if test_rc != 0:
        if log_cb:
            log_cb("  pip not found — bootstrapping via ensurepip...")
        rc = _run([python_exe, "-m", "ensurepip", "--upgrade"], "ensurepip")
        if rc != 0:
            if log_cb:
                log_cb("  FAIL ensurepip failed (exit %d). Install pip manually." % rc)
                log_cb(f'  TIP: Run as Admin: "{python_exe}" -m ensurepip --upgrade')
            return

    # ── Stage 2: upgrade pip itself ───────────────────────────────────────────
    _run([python_exe, "-m", "pip", "install", "--upgrade", "pip"], "pip self-upgrade")

    # ── Stage 3: install requested packages ──────────────────────────────────
    # IMPORTANT: never install or upgrade PySide6 — Max ships its own build.
    # Filter it out as a safety net even if it somehow ends up in the list.
    safe_packages = [p for p in packages if "pyside" not in p.lower()]
    if not safe_packages:
        if log_cb:
            log_cb("  No packages to install (all were filtered as Max-provided).")
        return

    cmd = [python_exe, "-m", "pip", "install", "--upgrade"] + safe_packages
    rc = _run(cmd, "package install")
    if rc == 0:
        if log_cb:
            log_cb("  OK pip install succeeded")
    else:
        if log_cb:
            log_cb(f"  FAIL pip install failed (exit {rc})")
            log_cb("  TIP: Some packages may need the Visual C++ Redistributable.")
            log_cb("  The scripts will still work without optional packages.")


# ---------------------------------------------------------------------------
# GUI Wizard
# ---------------------------------------------------------------------------

class InstallerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title(f"{BANNER} — Installer")
        self.resizable(False, False)
        self.geometry("600x500")
        self.configure(bg="#1e1e2e")

        self.versions = detect_max_versions()
        self.ver_vars = {}   # year → BooleanVar
        self.options = {
            "backup": tk.BooleanVar(value=True),
            "install_pip": tk.BooleanVar(value=True),
            "autostart": tk.BooleanVar(value=False),  # MCP auto-launch on Max startup
        }

        self._page = 0
        self._frame = None
        self._show_page(0)

    # ── helpers ────────────────────────────────────────────────────────────

    def _clear(self):
        if self._frame:
            self._frame.destroy()
        self._frame = tk.Frame(self, bg="#1e1e2e")
        self._frame.pack(fill="both", expand=True, padx=20, pady=20)

    def _label(self, parent, text, size=12, color="#cdd6f4", bold=False):
        font = ("Segoe UI", size, "bold" if bold else "normal")
        return tk.Label(parent, text=text, bg="#1e1e2e", fg=color,
                        font=font, wraplength=560, justify="left")

    def _button(self, parent, text, cmd, width=12):
        return tk.Button(parent, text=text, command=cmd,
                         bg="#89b4fa", fg="#1e1e2e", activebackground="#74c7ec",
                         font=("Segoe UI", 10, "bold"), relief="flat",
                         padx=10, pady=6, width=width, cursor="hand2")

    def _show_page(self, n):
        self._page = n
        [self._page0, self._page1, self._page2, self._page3][n]()

    # ── Page 0: Welcome ────────────────────────────────────────────────────

    def _page0(self):
        self._clear()
        f = self._frame
        self._label(f, "SoulBurn Scripts Pack", 20, "#89b4fa", bold=True).pack(pady=(10, 4))
        self._label(f, f"Version 2.0 for 3ds Max 2020–2027", 13, "#a6e3a1").pack()
        self._label(f, "─" * 60, 10, "#45475a").pack(pady=8)
        msg = (
            "89 productivity scripts for modeling, UVs, materials, cameras,\n"
            "rendering, splines, VFX, and AI-driven scene control.\n\n"
            f"Detected {len(self.versions)} Max installation(s) on this machine."
        )
        self._label(f, msg, 11, "#cdd6f4").pack(pady=10)
        self._label(f, "─" * 60, 10, "#45475a").pack(pady=8)
        self._button(f, "Next →", lambda: self._show_page(1), width=16).pack(side="bottom", pady=10)

    # ── Page 1: Version select ─────────────────────────────────────────────

    def _page1(self):
        self._clear()
        f = self._frame
        self._label(f, "Select Installation Targets", 14, "#89b4fa", bold=True).pack(anchor="w")
        self._label(f, "Detected 3ds Max versions:", 10, "#a6adc8").pack(anchor="w", pady=(4, 2))

        ver_frame = tk.LabelFrame(f, text="", bg="#313244", fg="#cdd6f4",
                                   relief="flat", padx=10, pady=6)
        ver_frame.pack(fill="x", pady=4)

        if not self.versions:
            self._label(ver_frame, "No 3ds Max installations found.", 10, "#f38ba8").pack()
        for v in self.versions:
            var = tk.BooleanVar(value=True)
            self.ver_vars[v["year"]] = var
            enu_path = v["enu_path"] or ""
            already, status_msg = (is_already_installed(enu_path)
                                   if enu_path else (False, "ENU path will be created"))
            status_color = "#a6e3a1" if already else "#f9e2af"
            row = tk.Frame(ver_frame, bg="#313244")
            row.pack(anchor="w", fill="x", pady=1)
            chk = tk.Checkbutton(
                row,
                text=f"3ds Max {v['year']}",
                variable=var, bg="#313244", fg="#cdd6f4",
                activebackground="#313244", selectcolor="#1e1e2e",
                font=("Segoe UI", 10, "bold"), width=14, anchor="w"
            )
            chk.pack(side="left")
            tk.Label(row, text=status_msg, bg="#313244", fg=status_color,
                     font=("Segoe UI", 9)).pack(side="left", padx=(4, 0))

        opt_frame = tk.LabelFrame(f, text="Options", bg="#313244", fg="#89b4fa",
                                   relief="flat", padx=10, pady=6)
        opt_frame.pack(fill="x", pady=8)
        tk.Checkbutton(opt_frame, text="Backup existing SoulburnScripts folder before overwriting",
                       variable=self.options["backup"], bg="#313244", fg="#cdd6f4",
                       activebackground="#313244", selectcolor="#1e1e2e",
                       font=("Segoe UI", 10)).pack(anchor="w")
        tk.Checkbutton(opt_frame, text="Install Atlas Bridge Python dependencies (fastmcp, pandas, shapely)",
                       variable=self.options["install_pip"], bg="#313244", fg="#cdd6f4",
                       activebackground="#313244", selectcolor="#1e1e2e",
                       font=("Segoe UI", 10)).pack(anchor="w")

        btn_row = tk.Frame(f, bg="#1e1e2e")
        btn_row.pack(side="bottom", pady=10, fill="x")
        self._button(btn_row, "← Back", lambda: self._show_page(0)).pack(side="left")
        self._button(btn_row, "Install", self._start_install, width=16).pack(side="right")

    # ── Page 2: Progress ───────────────────────────────────────────────────

    def _page2(self):
        self._clear()
        f = self._frame
        self._label(f, "Installing...", 14, "#89b4fa", bold=True).pack(anchor="w")
        self.progress_var = tk.DoubleVar(value=0)
        self.progress_bar = ttk.Progressbar(f, variable=self.progress_var,
                                             maximum=100, length=560)
        self.progress_bar.pack(pady=8)
        self.log_text = scrolledtext.ScrolledText(
            f, height=16, bg="#181825", fg="#cdd6f4",
            font=("Consolas", 9), relief="flat", wrap="word"
        )
        self.log_text.pack(fill="both", expand=True)
        self._done_button = self._button(f, "Please wait...", lambda: None, width=16)
        self._done_button.pack(side="bottom", pady=10)
        self._done_button.config(state="disabled")

    def _start_install(self):
        selected = [v for v in self.versions if self.ver_vars.get(v["year"], tk.BooleanVar()).get()]
        if not selected:
            messagebox.showwarning("No target selected",
                                   "Please select at least one Max version to install into.")
            return
        self._show_page(2)
        opts = {k: v.get() for k, v in self.options.items()}
        t = threading.Thread(target=self._do_install, args=(selected, opts), daemon=True)
        t.start()

    def _do_install(self, selected_versions, opts):
        total_vers = len(selected_versions)
        all_installed = 0

        def log(msg):
            self.log_text.insert("end", msg + "\n")
            self.log_text.see("end")
            self.update_idletasks()

        def prog(rel):
            nonlocal all_installed
            all_installed += 1
            self.progress_var.set(min(99, all_installed * 0.3))
            self.update_idletasks()

        for i, v in enumerate(selected_versions):
            log(f"\n{'─'*50}")
            already, status_msg = (is_already_installed(v["enu_path"])
                                   if v.get("enu_path") else (False, ""))
            if already:
                log(f"  Reinstalling over existing installation ({status_msg})")
            log(f"Installing into 3ds Max {v['year']}...")
            installed = install_to_version(v, opts, progress_cb=prog, log_cb=log)
            log(f"OK {len(installed)} files installed into Max {v['year']}")

            if opts.get("install_pip") and v.get("python_exe"):
                log(f"\nInstalling Python dependencies into Max {v['year']}...")
                run_pip(v["python_exe"], PYTHON_DEPS, log_cb=log)

        self.progress_var.set(100)
        log(f"\n{'═'*50}")
        log(f"DONE Installation complete! {total_vers} version(s) updated.")
        log("Open 3ds Max → Customize → Toolbars → Category: SoulburnScripts")

        self._done_button.config(text="Done →", state="normal",
                                  command=lambda: self._show_page(3))

    # ── Page 3: Finish ─────────────────────────────────────────────────────

    def _page3(self):
        self._clear()
        f = self._frame
        self._label(f, "Installation Complete!", 18, "#a6e3a1", bold=True).pack(pady=(20, 10))
        self._label(f, "Next Steps:", 12, "#89b4fa", bold=True).pack(anchor="w", pady=(10, 4))
        steps = (
            "1. Open 3ds Max\n"
            "2. Go to Customize → Customize User Interface → Toolbars\n"
            "3. Select Category: SoulburnScripts\n"
            "4. Drag any tool to your toolbar\n\n"
            "To use the Atlas Bridge (AI scene control):\n"
            "5. Run atlasBridgeLauncher from the SoulburnScripts toolbar\n"
            "6. Click START Bridge, then connect your MCP client to 127.0.0.1:9879"
        )
        self._label(f, steps, 11, "#cdd6f4").pack(anchor="w", padx=10)
        btn_row = tk.Frame(f, bg="#1e1e2e")
        btn_row.pack(side="bottom", pady=10, fill="x")
        readme = os.path.join(SOURCE_ROOT, "README.md")
        if os.path.exists(readme):
            self._button(btn_row, "Open README", lambda: os.startfile(readme)).pack(side="left")
        self._button(btn_row, "Close", self.destroy, width=10).pack(side="right")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    app = InstallerApp()
    app.mainloop()
