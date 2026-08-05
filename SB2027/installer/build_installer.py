"""
build_installer.py -- cx_Freeze 8.x build script for SoulBurn Scripts Installer
Run from SB2027/installer/ with:
    python build_installer.py build_exe

Output: SB2027/installer_dist/SoulburnScripts_v2_Setup.exe  +  lib/  subdir
"""

import sys
import os
from cx_Freeze import setup, Executable

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
HERE = os.path.dirname(os.path.abspath(__file__))          # SB2027\installer\
SB_ROOT = os.path.dirname(HERE)                            # SB2027\
DIST_DIR = os.path.join(SB_ROOT, "installer_dist")        # SB2027\installer_dist\

# ---------------------------------------------------------------------------
# Data files to bundle alongside the EXE
# Each tuple: (absolute-source, dest-relative-to-dist-root)
# These are the files installer.py reads via SOURCE_ROOT at runtime.
# ---------------------------------------------------------------------------
include_files = [
    # 3ds Max script content
    (os.path.join(SB_ROOT, "scripts"),      "scripts"),
    (os.path.join(SB_ROOT, "MacroScripts"), "MacroScripts"),
    (os.path.join(SB_ROOT, "UI_ln"),        "UI_ln"),
    # Optional: mcp server source
    (os.path.join(SB_ROOT, "max_mcp_server"), "max_mcp_server"),
    # Docs
    (os.path.join(SB_ROOT, "README.md"),    "README.md"),
    (os.path.join(SB_ROOT, "CHANGELOG.md"), "CHANGELOG.md"),
]

# Filter out entries where the source doesn't exist (graceful)
include_files = [(s, d) for s, d in include_files if os.path.exists(s)]

# ---------------------------------------------------------------------------
# Build options
# ---------------------------------------------------------------------------
build_exe_options = {
    "build_exe": DIST_DIR,
    "packages": [
        "tkinter",
        "winreg",
        "subprocess",
        "threading",
        "json",
        "shutil",
        "urllib.request",
        "email",
        "http",
        "logging",
    ],
    "excludes": [
        # Heavy packages we don't use in the installer itself
        "pandas",
        "numpy",
        "scipy",
        "matplotlib",
        "PIL",
        "PySide6",
        "PyQt5",
        "PyQt6",
        "fastmcp",
        "shapely",
        "test",
        "unittest",
        "pydoc",
        "doctest",
        "difflib",
        "lib2to3",
        "xmlrpc",
        "ftplib",
        "poplib",
        "imaplib",
        "smtplib",
        "sqlite3",
        "multiprocessing",
        "asyncio",
    ],
    "include_files": include_files,
    # Keep .pyc files zipped inside library.zip for a smaller footprint
    "zip_include_packages": "*",
    "zip_exclude_packages": [],
    "silent": False,
}

# ---------------------------------------------------------------------------
# cx_Freeze setup
# ---------------------------------------------------------------------------
setup(
    name="SoulBurnScriptsPack",
    version="2.0",
    description="SoulBurn Scripts Pack for 3ds Max — Installer",
    options={"build_exe": build_exe_options},
    executables=[
        Executable(
            script=os.path.join(HERE, "installer.py"),
            target_name="SoulburnScripts_v2_Setup.exe",
            base="Win32GUI",          # no console window; pure GUI app
        )
    ],
)
