"""
build_installer.py — cx_Freeze build script for SoulBurn Scripts Pack v2.0

Usage:
    python build_installer.py build_exe

Output:
    build/SoulburnScripts_v2_Setup.exe  (self-contained, ~50MB)

Requirements:
    pip install cx_Freeze
"""

import sys
import os
from cx_Freeze import setup, Executable

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
SOURCE_ROOT = os.path.dirname(SCRIPT_DIR)          # SB2027/
INSTALLER_DIR = os.path.join(SOURCE_ROOT, "installer")  # SB2027/installer/

# Data files to bundle into the EXE (the entire SB2027 release folder)
include_files = []

BUNDLE_DIRS = [
    "scripts",
    "MacroScripts",
    "UI_ln",
    "max_mcp_server",
]
for d in BUNDLE_DIRS:
    src = os.path.join(SOURCE_ROOT, d)
    if os.path.isdir(src):
        include_files.append((src, d))

# Also include README and CHANGELOG
for f in ("README.md", "CHANGELOG.md"):
    src = os.path.join(SOURCE_ROOT, f)
    if os.path.isfile(src):
        include_files.append((src, f))

# ---------------------------------------------------------------------------
# cx_Freeze configuration
# ---------------------------------------------------------------------------

build_exe_options = {
    "packages": ["tkinter", "winreg", "shutil", "json", "subprocess",
                 "threading", "os", "sys"],
    "include_files": include_files,
    "build_exe": os.path.join(INSTALLER_DIR, "dist"),
    "optimize": 2,
    "silent_level": 1,
}

target = Executable(
    script=os.path.join(INSTALLER_DIR, "installer.py"),
    target_name="SoulburnScripts_v2_Setup.exe",
    base="Win32GUI",
    icon=os.path.join(INSTALLER_DIR, "installer_icon.ico")
    if os.path.exists(os.path.join(INSTALLER_DIR, "installer_icon.ico"))
    else None,
    shortcut_name="SoulBurn Scripts v2.0 Setup",
    shortcut_dir="DesktopFolder",
    copyright="SoulBurn 2027 Community",
)

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

setup(
    name="SoulBurn Scripts Pack",
    version="2.0",
    description="SoulBurn Scripts Pack v2.0 for 3ds Max 2020-2027",
    author="Neil Blevins / SoulBurn 2027 Community",
    options={"build_exe": build_exe_options},
    executables=[target],
)

# ---------------------------------------------------------------------------
# Post-build: rename exe from dist/ to parent folder
# ---------------------------------------------------------------------------

if __name__ == "__main__" and len(sys.argv) > 1 and "build_exe" in sys.argv:
    dist_dir = os.path.join(INSTALLER_DIR, "dist")
    built_exe = os.path.join(dist_dir, "SoulburnScripts_v2_Setup.exe")
    final_exe = os.path.join(SOURCE_ROOT, "SoulburnScripts_v2_Setup.exe")
    if os.path.exists(built_exe):
        import shutil
        shutil.copy2(built_exe, final_exe)
        print(f"\nOK EXE built: {final_exe}")
    else:
        print(f"\nWARN EXE not found at {built_exe}. Check build output.")
