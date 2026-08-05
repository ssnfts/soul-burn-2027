# SoulBurn Scripts Pack v2.0 for 3ds Max 2025–2027

> Community-maintained update of Neil Blevins' legendary SoulBurn Scripts Pack.  
> Original pack v1.12 by Neil Blevins. This v2.0 update by the SoulBurn 2027 community.

---

## What Is This?

SoulBurn Scripts Pack is a collection of **89 productivity scripts** for Autodesk 3ds Max, covering:

- 🎨 **Modeling** — geometry banger, subdivision manager, edge tools, spline painter
- 📐 **UV** — UV flattener, placer, transfer, flatten mapper, area displayer
- 🎭 **Materials** — material mover, Arnold/Corona/VRay/Physical material managers
- 📷 **Cameras** — physical camera manager, cinematic camera maker
- 🏗️ **Scene** — object dropper, painter, replacer, layer/selection tools
- 🤖 **AI/Atlas** — Atlas MCP bridge launcher, cinematic scene builder
- 🔥 **VFX** — tyFlow FX launcher (tyre smoke, crash debris, sparks)
- 🌐 **Export** — glTF/glb export helper with pre-flight validation
- 🗺️ **OSL** — OSL map browser

---

## New in v2.0 (2027 Update)

| Feature | Details |
|---------|---------|
| **Arnold Material Manager** | Batch-set subdivision, displacement, opacity on Arnold Standard Surface |
| **Corona Material Manager** | Batch-set displacement, glossiness, GI exclusion on CoronaMtl |
| **Physical Camera Manager** | Batch ISO, f-stop, shutter, focal length, WB across all Physical Cameras |
| **OSL Map Browser** | Browse and assign .osl/.oso maps from Max's OSL directories |
| **glTF Export Helper** | Pre-flight validation + guided glTF/glb export |
| **Cinematic Camera Maker** | 10 professional camera moves via cinecam.py (Arc, Dolly, Helix, etc.) |
| **tyFlow FX Launcher** | Generate tyre smoke / crash debris / sparks tyFlow graphs from UI |
| **Atlas Bridge Launcher** | Start/Stop/Ping the Atlas MCP bridge for AI-driven scene control |
| **Atlas Cinematic Scene Builder** | Build full real-world scenes (OSM buildings + terrain + sun + camera) |

### Compatibility Fixes (v2.0)
- ✅ **sLib.ms** — renderer detection rewritten (no fragile class IDs), `sLibGetSafeUIPos`, `doesFileExist`, `toUpper/toLower`
- ✅ **splinePainter.ms** — completely rewritten using `MouseTrack` (thePainterInterface removed in Max 2020)
- ✅ **materialMover.ms** — Brazil 1/2 and Mental Ray presets replaced with Physical, Arnold, Corona, glTF
- ✅ **geometryBanger.ms** — biased random distribution fixed (`random 1 2`)
- ✅ **objectDropper.ms** — magic `+100` ray offsets replaced with scene-bounds derived offset
- ✅ **edgeSelectByAngle.ms** — epsilon `0.001°` corrected to `0.1°`
- ✅ **subdivisionManager.ms** — MeshSmooth path wrapped in `try/catch`, falls back to TurboSmooth
- ✅ **transformRandomizer.ms** — reproducible seed field added
- ✅ All `execute(getINISetting(...))` calls replaced with typed reads (no arbitrary code execution)

---

## Requirements

- **3ds Max** 2020–2027 (tested on 2027)
- **Renderers** (optional): Arnold 7+, V-Ray 6/7, Corona 10/11
- **Python bridge** (optional): Python 3.10+ with `PySide6`, `fastmcp`, `pandas`, `shapely`

---

## Installation

### Automatic (Recommended)

> ⚠️ **IMPORTANT — How to run the installer:**
>
> The installer is a **folder-based package** (cx_Freeze). The EXE must be run from
> inside the `installer_dist\` folder — it needs the `lib\` folder beside it to work.
>
> **Do one of these:**
> - Double-click **`RUN_INSTALLER.bat`** in the `SB2027\` folder ← easiest
> - Or open `SB2027\installer_dist\` and double-click `SoulburnScripts_v2_Setup.exe` from there


### Manual
Copy these folders to your 3ds Max user folder:
```
%LOCALAPPDATA%\Autodesk\3dsMax\{VERSION} - 64bit\ENU\
```

| Source | Destination |
|--------|-------------|
| `scripts\SoulburnScripts\` | `{ENU}\scripts\SoulburnScripts\` |
| `MacroScripts\SoulburnScripts.mcr` | `{ENU}\scripts\Startup\` |
| `MacroScripts\SoulburnScriptsExtras.mcr` | `{ENU}\scripts\Startup\` |
| `UI_ln\Icons\` | `{ENU}\UI_ln\Icons\` |
| `UI_ln\IconsDark\` | `{ENU}\UI_ln\IconsDark\` |

Then restart 3ds Max and go to **Customize → Toolbars → Category: SoulburnScripts** to add buttons.

---

## Adding Buttons to Toolbar

1. Open 3ds Max
2. Go to **Customize → Customize User Interface → Toolbars**
3. Select Category: **SoulburnScripts**
4. Drag any script button to your toolbar

> 💡 **Every tool has its own individual button** — not dropdowns — so you can assign keyboard shortcuts to individual modes.

---

## Atlas Bridge (AI Scene Control)

The **Atlas MCP Bridge** lets AI agents (Claude, GPT-4o, etc.) control 3ds Max:

1. In Max, run **atlasBridgeLauncher** (SoulburnScripts category)
2. Click **START Bridge**
3. Connect your MCP client to `127.0.0.1:9879`
4. See `max_mcp_server/SYSTEM_PROMPT.md` for agent instructions

**Install Python dependencies** (run once):
```
{MaxInstallDir}\Python\python.exe -m pip install PySide6 fastmcp pandas shapely
```

---

## Script Quick Reference

### New in v2.0
| Script | Default Action | UI Version |
|--------|---------------|------------|
| `arnoldMaterialManager` | Apply defaults to Arnold mats | `arnoldMaterialManagerUI` |
| `coronaMaterialManager` | Apply defaults to Corona mats | `coronaMaterialManagerUI` |
| `physicalCameraManager` | Apply defaults to Physical Cams | `physicalCameraManagerUI` |
| `oslMapBrowser` | — | `oslMapBrowserUI` |
| `gltfExportHelper` | — | `gltfExportHelperUI` |
| `cinematicCameraMaker` | — | `cinematicCameraMakerUI` |
| `tyflowFXLauncher` | — | `tyflowFXLauncherUI` |
| `atlasBridgeLauncher` | — | `atlasBridgeLauncherUI` |
| `atlasCineSceneBuilder` | — | `atlasCineSceneBuilderUI` |

---

## Credits

- **Original SoulBurn Scripts Pack v1.12** — Neil Blevins ([neilblevins.com](http://neilblevins.com))
- **v2.0 Update** — SoulBurn 2027 Community
- **cinecam.py** — Cinematic camera move algorithms
- **tyfx.py / raceanim.py** — tyFlow FX generation
- **max_mcp_server** — Atlas MCP bridge for AI scene control

---

## License

Original scripts: Copyright © Neil Blevins. Used with attribution.  
v2.0 additions: MIT License. See LICENSE file.
