# SoulBurn Scripts Pack v2.0 for 3ds Max 2025–2027

A community update of Neil Blevins' SoulBurn Scripts Pack: about 90
productivity scripts for Autodesk 3ds Max, repaired for current versions and
extended with new tools for modern renderers, cameras, effects and AI-driven
scene building.

> Original pack v1.12 by Neil Blevins
> ([neilblevins.com](http://neilblevins.com)). The original scripts remain
> his work and are used with attribution. The v2.0 additions are by the
> SoulBurn 2027 community.

## What it does

The pack adds a **SoulburnScripts** category of toolbar buttons to 3ds Max.
Every tool has its own button, so each one can also be given a keyboard
shortcut.

| Area | Examples |
|---|---|
| Modelling | geometry banger, subdivision manager and automator, edge divider, spline painter, pipe and wire makers |
| UV | UV flattener, placer, transfer, flatten mapper, area displayer |
| Materials | material mover, remover and info displayer; Arnold, Corona and V-Ray managers; V-Ray material lab; texmap baker and preview |
| Cameras | physical camera manager, camera from perspective view, cinematic camera maker |
| Scene | object dropper, painter, replacer, attacher and detacher; name manager; instance and selection tools; pivot placer |
| Lighting | custom lighting assistant, smart lighting |
| Effects | tyFlow FX launcher for tyre smoke, crash debris and sparks |
| Export | glTF/glb export helper with checks before export |
| AI | Atlas bridge launcher and Atlas cinematic scene builder, which let an AI agent build real-world scenes |

### New in v2.0

- Arnold, Corona and Physical Camera batch managers
- OSL map browser
- glTF export helper
- Cinematic camera maker with ten camera moves
- tyFlow FX launcher
- Atlas bridge launcher and cinematic scene builder
- Fixes across the original scripts for APIs removed since 3ds Max 2020,
  including a rewritten spline painter and renderer detection, and typed
  settings reads in place of executing settings text as code

The full list of changes is in [SB2027/CHANGELOG.md](SB2027/CHANGELOG.md).

## Prerequisites

- **3ds Max 2020–2027** on Windows. Tested on 3ds Max 2027.
- Optional renderers for the matching tools: Arnold 7+, V-Ray 6 or 7,
  Corona 10 or 11.
- Optional: [tyFlow](https://pro.tyflow.com/) for the FX launcher.
- Optional, for the Atlas tools: Python packages installed into 3ds Max's
  own Python (see step 3 below).

## Install

The v2.0 pack is in the [`SB2027/`](SB2027/) folder. The folders at the top
of the repository are the original v1.12 files, kept for reference.

**1. Copy the files.** Download or clone this repository, then copy from
`SB2027/` into your 3ds Max user folder:

```
%LOCALAPPDATA%\Autodesk\3dsMax\<version> - 64bit\ENU\
```

| From `SB2027/` | To the user folder |
|---|---|
| `scripts\SoulburnScripts\` | `scripts\SoulburnScripts\` |
| `scripts\Startup\` | `scripts\Startup\` |
| `MacroScripts\SoulburnScripts.mcr` | `scripts\Startup\` |
| `MacroScripts\SoulburnScriptsExtras.mcr` | `scripts\Startup\` |
| `UI_ln\` | `UI_ln\` |

**2. Restart 3ds Max**, then open **Customize > Customize User Interface >
Toolbars**, choose the category **SoulburnScripts** and drag the buttons you
want onto a toolbar.

**3. Optional, for the Atlas tools.** Run once, using your 3ds Max install
folder:

```
"C:\Program Files\Autodesk\3ds Max 2027\Python\python.exe" -m pip install PySide6 fastmcp pandas shapely
```

### Installer

`SB2027/INSTALL.bat` runs a Windows installer that finds your 3ds Max
versions and copies everything for you. The installer program is not stored
in this repository. Build it first, with Python and `cx_Freeze` installed:

```
cd SB2027\installer
python build_installer.py build_exe
```

That creates `SB2027\installer_dist\`. Run `INSTALL.bat` afterwards, and keep
the EXE next to its `lib\` folder.

## How to use it

- Most tools come in two forms: the plain button applies the tool with its
  saved defaults, and the **UI** button opens its dialogue so you can change
  the settings.
- Select the objects you want to affect first. Most tools act on the current
  selection.
- **soulburnScriptsLister** lets you pick any script in the pack from a
  dropdown list and run it, which is the quickest way to try a tool before
  giving it a button.
- **Atlas bridge**: run **atlasBridgeLauncher**, press **START Bridge**, then
  connect an MCP client. Agent instructions are in
  [SB2027/max_mcp_server/SYSTEM_PROMPT.md](SB2027/max_mcp_server/SYSTEM_PROMPT.md).

More detail is in [SB2027/README.md](SB2027/README.md).

## Getting the best result

- **Save or hold the scene before batch tools.** The managers change every
  matching material or camera in one click.
- **Build one toolbar per task** (modelling, UV, look development) instead
  of one long toolbar, and assign shortcuts to the handful you use daily.
- **Use the UI version first.** Set a tool up once in its dialogue; the
  plain button then repeats those settings in one click.
- **Use the seed in transformRandomizer** when a layout has to be
  reproducible between sessions or artists.
- **Run the glTF export helper's checks** before exporting for web or
  real-time use, and fix what it reports first.
- **Match the manager to the renderer.** The Arnold, Corona and V-Ray
  managers only touch their own material types.

## Works well with

**Graphic design.** Object painter, dropper and the randomizers scatter
props and build dense still-life layouts quickly; wire colour and ID tools
give clean masks for compositing in Photoshop or Affinity.

**Product visualization.** The material managers and physical camera manager
keep a range of products consistent across many shots, and the glTF export
helper sends the same model to a web viewer or AR. Pair with
[V-Ray material graph builder](https://github.com/ssnfts/V-Ray-material-graph-builder)
and [Motorsport vehicle rig](https://github.com/ssnfts/Motorsport-lap-animation).

**Film.** Cinematic camera maker for the moves, tyFlow FX launcher for
smoke, debris and sparks, and the Atlas scene builder for real locations
with a correct sun. The standalone versions are
[Cinematic camera moves](https://github.com/ssnfts/Cinematic-camera-moves),
[tyFlow script generator](https://github.com/ssnfts/tyFlow-script-generator)
and [Atlas](https://github.com/ssnfts/atlas).

**Automation.** The Atlas bridge lets an AI agent or a script drive 3ds Max;
see [3dsmax-mcp](https://github.com/ssnfts/3dsmax-mcp). Every tool is also a
macro, so it can be called from your own MAXScript or bound into a batch
process.

## Repository layout

```
SB2027/                 the v2.0 pack
  scripts/              the tools and their shared library
  MacroScripts/         button and macro definitions
  UI_ln/                icons
  max_mcp_server/       Atlas bridge and MCP server
  installer/            installer source
  CHANGELOG.md
MacroScripts/ scripts/ UI_ln/    the original v1.12 pack
```

## Credits and licence

- **Original SoulBurn Scripts Pack v1.12**: Neil Blevins. Copyright remains
  with him; used with attribution.
- **v2.0 update**: SoulBurn 2027 community.
- The v2.0 additions are intended to be MIT licensed. This repository does
  not yet contain a licence file.
