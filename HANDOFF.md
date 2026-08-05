# Handoff Document — SoulBurn Scripts Pack v2.0 for 3ds Max 2025–2027
**Session handoff compiled:** Auto-generated  
**Project root:** `c:\Users\mabdu\Downloads\SoulburnScriptsPack_3dsMax_v112_R2013toR2022\`  
**Active workspace:** `SB2027\`

---

## 1. Project Overview

SoulBurn Scripts Pack v2.0 is a community-maintained update of Neil Blevins' legendary SoulBurn Scripts Pack v1.12 (last updated 2017, targeting 3ds Max R2013–R2022). The goal is to produce a fully compatible, installer-distributed toolkit of **89 productivity MaxScripts** that runs on **3ds Max 2025–2027** with modern renderer support (Arnold 7+, V-Ray 6/7, Corona 10/11, Physical Material).

The work spans:
- **Bug-fixing and modernising** the existing 87 scripts (typed INI reads, renderer detection, deprecated API removal).
- **Adding 9 new scripts** (Arnold/Corona material managers, Physical Camera manager, OSL browser, glTF exporter, cinematic camera maker, tyFlow FX launcher, Atlas MCP bridge, cinematic scene builder).
- **Integrating three standalone Python modules** from sibling repos (`cinematic_cameras/`, `tyflow_scripts/`, `max_mcp_server/`).
- **Adding a new MaxMaze tool**, a **custom lighting assistant** (from `COURSE-WEEK-3.md`), and **improved tyFlow UI controls**.
- **Shipping a Windows installer EXE** with registry-based Max version detection.
- **Creating unique custom icons** for every button and implementing a **floating toolbar auto-installer** that appears immediately after the installer finishes.

---

## 2. Repository Layout

```
SoulburnScriptsPack_3dsMax_v112_R2013toR2022/    ← workspace root
├── SB2027/                                       ← main deliverable
│   ├── MacroScripts/
│   │   ├── SoulburnScripts.mcr                  ← all macro registrations (Default + UI per script)
│   │   ├── SoulburnScriptsExtras.mcr
│   │   └── SoulburnScripts.cuix                  ← toolbar/UI state file
│   ├── scripts/SoulburnScripts/
│   │   ├── lib/
│   │   │   └── sLib.ms                          ← shared library (v2.00)
│   │   └── scripts/                             ← 89 individual .ms tools
│   ├── installer/                               ← Python-source installer
│   ├── installer_dist/                          ← cx_Freeze compiled EXE
│   │   └── README.md                            ← end-user README
│   ├── CHANGELOG.md                             ← full change history
│   ├── README.md
│   └── dev/                                     ← dev notes/scratch
├── UI_ln/                                       ← icon bitmaps (16a/16i/24a/24i per action)
│   ├── Icons/                                   ← light-theme icons (2242+ BMP files)
│   └── IconsDark/                               ← dark-theme icons
├── cinematic_cameras/                           ← standalone camera-move algorithms (Python)
│   └── server/                                  ← cinecam.py (10 move types)
├── tyflow_scripts/                              ← standalone tyFlow code generator (Python)
│   └── server/
│       ├── tyfx.py                              ← tyre smoke / crash debris / sparks
│       └── raceanim.py                          ← race animation helpers
├── max_mcp_server/                              ← Atlas MCP bridge (Python)
│   ├── bridge/                                  ← atlas_max_bridge.py, atlas_max_handlers.py, start_bridge.py
│   └── server/
├── soulburn-2027-update-plan.md                 ← THE master spec (read this first)
└── MacroScripts/                                ← workspace-root legacy copy
```

---

## 3. Key Reference Documents

| Document | Purpose |
|---|---|
| `soulburn-2027-update-plan.md` | **Master specification.** Full code-quality audit (13 issues), feature audit (obsolete/needs update/still valuable), 13 sub-tasks with todo lists, integration specs for all three Python sub-repos. **READ THIS FIRST.** |
| `SB2027/CHANGELOG.md` | What has been done in v2.00 so far. |
| `SB2027/installer_dist/README.md` | End-user installation instructions. |
| `SB2027/MacroScripts/SoulburnScripts.mcr` | All macro registrations; add entries here when adding scripts. |
| `max_mcp_server/SYSTEM_PROMPT.md` | Agent instructions for the Atlas MCP bridge. |
| `C:\Users\mabdu\Downloads\scripts\max_maze.py` | **MaxMaze source** — recursive back-tracker maze generation on Editable Poly (to be integrated with custom UI). |
| `C:\Users\mabdu\Downloads\scripts\COURSE-WEEK-3.md` | **Lighting course notes** — GI, AOVs, light filters, light groups, bounces. Source material for the new custom lighting assistant feature. |

---

## 4. Current Status (What Has Been Completed)

> Reference `SB2027/CHANGELOG.md` for the full authoritative list.

The v2.00 tag includes these **completed deliverables**:

### 4.1 sLib.ms Updates (v1.50 → v2.00)
- `sLibWhatsCurrentRenderer()` — rewritten using `matchPattern` (no fragile class IDs).
- `sLibGetSafeUIPos(w, h)` — new, replaces hardcoded `[400,400]`.
- `sLibAtlasBridgeCall(cmdName, paramsObj)` — .NET TCP socket helper for the Atlas bridge.
- `sLibGetArnoldLightMaps()`, `sLibGetCoronaLightMaps()`, `sLibGetAllPhysicalMaterials()` — new.
- `sLibArnoldTest()`, `sLibCoronaTest()` — new.
- Brazil 1/2 always returns `false` (classes removed).
- `sLibFileExist()` rewritten with `doesFileExist`.
- `sLibMakeStringLowercase/Uppercase` now uses built-in `toLower`/`toUpper`.
- Typo fixed: `return udnefined` → `return undefined`.

### 4.2 Script Bug Fixes Applied
| Script | Fix |
|---|---|
| `splinePainter.ms` | Completely rewritten using `MouseTrack` (replaced removed `thePainterInterface`) |
| `geometryBanger.ms` | Biased random fixed: `(random 0.00 1.99) as integer` → `(random 1 2)` |
| `objectDropper.ms` | Magic `+100` ray offsets replaced with scene-bounding-box derived `rayOffset` |
| `edgeSelectByAngle.ms` | Epsilon fixed: `0.001` → `0.1` degrees |
| `subdivisionManager.ms` | MeshSmooth path wrapped in `try/catch`; falls back to TurboSmooth |
| `materialMover.ms` | Brazil 1/2 and Mental Ray preset literals removed; updated for Physical/Arnold/Corona/glTF |
| `transformRandomizer.ms` | Seed spinner added; `seed()` called before randomization loop |

### 4.3 New Scripts Delivered
All 9 new scripts are present in `SB2027/scripts/SoulburnScripts/scripts/`:
- `arnoldMaterialManager.ms` — batch Arnold Standard Surface property control.
- `coronaMaterialManager.ms` — batch CoronaMtl property control.
- `physicalCameraManager.ms` — batch Physical Camera parameters.
- `oslMapBrowser.ms` — OSL/OSO file browser and material slot assignment.
- `gltfExportHelper.ms` — pre-flight validation + guided glTF/glb export.
- `cinematicCameraMaker.ms` — 10 camera moves via cinecam.py.
- `tyflowFXLauncher.ms` — tyre smoke / crash debris / sparks via tyfx.py.
- `atlasBridgeLauncher.ms` — Start/Stop/Ping the Atlas MCP bridge.
- `atlasCineSceneBuilder.ms` — full cinematic scene builder via Atlas bridge.

### 4.4 MacroScripts
`SoulburnScripts.mcr` bumped to v2.00. Default + UI macros added for all 9 new scripts, each with individual `Icon:#(...)` entries.

### 4.5 Installer
- `installer/installer.py` — Python tkinter 3-page wizard with registry-based Max 2020–2027 detection.
- `installer/build_installer.py` — cx_Freeze build script.
- `installer_dist/SoulburnScripts_v2_Setup.exe` — compiled installer EXE.
- `installer_dist/README.md` and `SB2027/CHANGELOG.md` — documentation delivered.

---

## 5. Open / Remaining Work (Next Session Priorities)

This section describes **all pending work** the next agent must implement. Items are ordered by priority.

---

### 5.1 PRIORITY 1 — Custom Unique Icons for Every Button

**This is blocking the toolbar and the overall polish of the release.**

Every SoulBurn tool needs four uniquely designed icon variants:
- `SoulburnScripts_{scriptName}_16a.bmp` — 16×16 active (light theme)
- `SoulburnScripts_{scriptName}_16i.bmp` — 16×16 inactive (light theme)
- `SoulburnScripts_{scriptName}_24a.bmp` — 24×24 active (light theme)
- `SoulburnScripts_{scriptName}_24i.bmp` — 24×24 inactive (light theme)

The same four must also exist under `UI_ln/IconsDark/` (darker background versions).

**Scripts that are completely missing icon sets (must be created from scratch):**
- `arnoldMaterialManager` / `arnoldMaterialManagerUI`
- `coronaMaterialManager` / `coronaMaterialManagerUI`
- `physicalCameraManager` / `physicalCameraManagerUI`
- `oslMapBrowser` / `oslMapBrowserUI`
- `gltfExportHelper` / `gltfExportHelperUI`
- `cinematicCameraMaker` / `cinematicCameraMakerUI`
- `tyflowFXLauncher` / `tyflowFXLauncherUI`
- `atlasBridgeLauncher` / `atlasBridgeLauncherUI`
- `atlasCineSceneBuilder` / `atlasCineSceneBuilderUI`
- `maxMazeGenerator` / `maxMazeGeneratorUI` ← new (see §5.3)
- `customLightingAssistant` / `customLightingAssistantUI` ← new (see §5.4)

**Icon design rules (must match the existing SoulBurn style):**
- BMP format, exact pixel dimensions (16×16 and 24×24).
- Active (`_a`) variants are fully coloured; inactive (`_i`) variants are desaturated (~50% grey).
- Dark variants have slightly lighter stroke/fill to remain visible on the dark Max UI background.
- Each icon must be visually distinct and clearly represent the tool's function — NOT generic gear/star icons.
- Suggested design approach: use Python `Pillow` to generate BMP icons programmatically with distinctive shapes for each category (Arnold = orange sphere, Corona = blue flame, Physical Camera = lens aperture, OSL = wave node, glTF = export arrow, Cinematic Camera = clapperboard, tyFlow = particle burst, Atlas = AI network node, MaxMaze = grid maze, Lighting Assistant = light bulb with AOV rings).

**Icon registration:** Each icon pair must be referenced in `SoulburnScripts.mcr` via the `Icon:#("SoulburnScripts_scriptName", index)` syntax. Confirm existing scripts in `UI_ln/Icons/` follow the same `SoulburnScripts_scriptName_SIZEstate.bmp` naming convention.

---

### 5.2 PRIORITY 2 — Floating Toolbar Auto-Installer (Post-Installation Feature)

When the installer completes, 3ds Max should automatically present a **pre-configured SoulBurn floating toolbar** the first time Max is launched after installation — no manual dragging from the Customize dialog.

**How this works in MaxScript:**
- `soulburnToolbarAutoCreate.ms` already exists in the scripts folder. This needs to be extended / verified.
- The `.cuix` file (`SB2027/MacroScripts/SoulburnScripts.cuix`) stores the toolbar layout. This should be pre-populated with all 89 tool buttons in a logical grouping.
- The installer should copy `SoulburnScripts.cuix` into `{ENU}\UI_ln\` alongside the icon files. On next Max startup, Max reads this and the floating toolbar appears.

**Implementation tasks:**
1. **Audit `soulburnToolbarAutoCreate.ms`** — verify it creates a dockable/floating toolbar with `cui.loadConfig` or direct toolbar-creation MaxScript API calls.
2. **Populate `SoulburnScripts.cuix`** — open 3ds Max manually, arrange all 89 buttons in a floating toolbar, then export the `.cuix` via `Customize → Save Custom UI Scheme`. Add this exported `.cuix` to the installer file set.
3. **Installer integration** — after the file copy step, the installer should also copy `SoulburnScripts.cuix` into `{ENU}\UI_ln\` (or prompt the user to apply it). Add this as a step in `installer.py`.
4. **First-run startup script** — add a small MaxScript startup file (`SB2027/MacroScripts/SoulburnStartup.ms`) that runs once on first load: checks if the toolbar already exists via `cui.getToolbar "SoulburnScripts"`, creates it if not, and sets a `plugcfg` flag so it only runs once.
5. **README update** — document the floating toolbar feature in `SB2027/installer_dist/README.md`.

---

### 5.3 PRIORITY 3 — MaxMaze Generator (New Script Integration)

**Source file:** `C:\Users\mabdu\Downloads\scripts\max_maze.py`

This is a fully functional recursive back-tracker maze generation algorithm that operates on any Editable Poly in 3ds Max. It needs to be wrapped as a first-class SoulBurn tool with a MaxScript UI shell that calls the Python script.

**About the algorithm (`max_maze.py`):**
- Builds a face-adjacency graph from shared interior edges of a selected Editable Poly.
- Runs a recursive back-tracker to produce a spanning-tree maze.
- Optional braiding (adds loops, `BRAID` 0.0–1.0) to produce non-perfect mazes.
- Extrudes "wall" faces up by `DEPTH` world units to produce raised 3D walls.
- Optional `WALL_WIDTH` bevel inset (0.0–0.5) controls passage width.
- Performance note in source: `# ponytail: face-lookup is O(edges); fine for grids up to ~10k faces.`

**Integration tasks:**
1. **Copy `max_maze.py` into** `SB2027/scripts/SoulburnScripts/lib/maze/max_maze.py`.
2. **Write `maxMazeGenerator.ms`** — MaxScript UI wrapper:
   - Spinner: **Seed** (int, default 42)
   - Spinner: **Braid** (float 0.0–1.0, default 0.0, label "Braid/Loops")
   - Spinner: **Wall Depth** (float 0.0+, default 2.0, label "Wall Height (units)")
   - Spinner: **Wall Width** (float 0.0–0.5, default 0.3, label "Wall Inset Fraction")
   - Button: **Generate Maze on Selection** — calls `python.ExecuteFile mazePath` with parameter injection via a temp `.py` wrapper that sets `SEED`, `BRAID`, `DEPTH`, `WALL_WIDTH` before calling `run_maze()`.
   - Button: **Flatten (Remove Walls)** — calls `run_maze(depth=0)` to reset the mesh to 2D selection.
   - Checkbox: **Auto-convert to Editable Poly** (default on).
   - Status label: shows last result ("Done — N passages, M wall faces").
3. **Parameter injection pattern:**
   ```maxscript
   local tmpPy = (getDir #temp) + "\\sb_maze_run.py"
   local f = openFile tmpPy mode:"w"
   format "import sys, importlib.util\n" to:f
   format "spec = importlib.util.spec_from_file_location('max_maze', r'%')\n" mazePyPath to:f
   format "mod = importlib.util.module_from_spec(spec)\n" to:f
   format "spec.loader.exec_module(mod)\n" to:f
   format "mod.SEED = %\n" seedVal to:f
   format "mod.BRAID = %\n" braidVal to:f
   format "mod.DEPTH = %\n" depthVal to:f
   format "mod.WALL_WIDTH = %\n" wallWidthVal to:f
   format "mod.run_maze()\n" to:f
   close f
   python.ExecuteFile tmpPy
   ```
4. **Register in `SoulburnScripts.mcr`** — add `maxMazeGenerator` (Default) and `maxMazeGeneratorUI` (UI) macros.
5. **Create icons** — see §5.1 (maze grid motif recommended).

---

### 5.4 PRIORITY 4 — Custom Lighting Assistant (New Feature from COURSE-WEEK-3.md)

**Source material:** `C:\Users\mabdu\Downloads\scripts\COURSE-WEEK-3.md`

This is a 3ds Max lighting workflow assistant informed by Iván M. Benítez Sanz's Week 3 lighting course. It encapsulates professional lighting concepts (GI, AOVs, light filters, light groups, bounce lighting) into a guided MaxScript UI that helps artists set up production-quality lighting rigs.

**Concepts to encode (from the course notes):**

| Concept | UI Feature |
|---|---|
| GI / Indirect Lighting | Toggle GI on/off; slider for number of GI bounces; note on noise vs render time trade-off |
| Fake Bounce Lights | "Add Bounce Fill Light" button — creates an omni/area light aimed at the subject with spread forced to 1, no specular, colour sampled from selected surface |
| AOV Management | Checkbox list: Diffuse, Specular, SSS, Emission, Depth (Z), Position, UVs, Normals; "Enable AOVs" button wires these into Arnold/Corona/VRay render settings |
| Light Groups | "Assign Light Group" button — prompts for a group name and sets the Arnold/Corona AOV light group attribute on selected lights |
| Light Filters (Arnold) | "Add Gobo" / "Add Barndoor" / "Add Light Decay" / "Add Light Blocker" buttons, each with preset parameters and a brief tooltip |
| Merge AOVs to EXR | Checkbox: merge all enabled AOVs into a single multi-channel EXR |

**Implementation tasks:**
1. **Write `customLightingAssistant.ms`** — multi-tab rollout:
   - **Tab 1: Indirect Lighting** — GI bounce count spinners (Arnold/Corona), fake bounce light creator.
   - **Tab 2: AOV Setup** — renderer-aware AOV checklist; enable/disable per renderer via `sLibWhatsCurrentRenderer()`.
   - **Tab 3: Light Groups** — list of scene lights with group name assignment; "Create Light Group AOV" button.
   - **Tab 4: Light Filters** — selected-light filter adder for Gobo/Barndoor/Decay/Blocker.
   - Status bar: "Current renderer: Arnold 7" (auto-detected from `sLibWhatsCurrentRenderer()`).
2. **Renderer-specific AOV paths:**
   - **Arnold:** AOV manager via `renderers.current.aov_manager` → add `aiAOV` nodes. Light group: `light.aiAovLightGroupPrefix`.
   - **Corona:** Corona Frame Buffer AOVs via `renderers.current.cfb_Enabled_Passes`. Light group: `light.effectID`.
   - **V-Ray:** V-Ray VFB channels via `vrayVFBChannels`. Light group: V-Ray Light's `include_exclude` and light select render element.
3. **Fake Bounce Light creator logic:**
   - Pick a selected surface → sample its `wirecolor` or material diffuse colour.
   - Create a `Omni` or `Target Area Light` placed opposite the key light relative to the subject.
   - Set `multiplier` to a low value (default 0.15), set specular contribution to 0, spread = 1 (per course notes).
4. **Register in `SoulburnScripts.mcr`** — `customLightingAssistant` + `customLightingAssistantUI`.
5. **Create icons** — see §5.1 (light bulb with AOV pass rings recommended).

---

### 5.5 PRIORITY 5 — tyFlow FX Launcher UI Improvements

The existing `tyflowFXLauncher.ms` provides a three-tab UI for tyre smoke / crash debris / crash sparks. The following improvements are needed to make it production-ready:

**Parameter improvements per effect type:**

| Effect | Current Params | Additions Needed |
|---|---|---|
| Tyre Smoke | Basic smoke density | Per-wheel toggle (FL/FR/RL/RR); tyre object picker (drag-and-drop node ref); smoke colour gradient picker; wind direction + speed |
| Crash Debris | Piece count, velocity | Debris size min/max; material assignment slot; secondary bounce count; settle friction |
| Crash Sparks | Count, lifetime | Spark colour (hot→cool gradient); gravity scale; emit shape (point/line/surface); render type (ticks/glints) |

**Architectural improvements:**
1. **Preview mode** — "Dry Run" checkbox that prints the generated MaxScript to the Max listener without executing it, so artists can inspect before running.
2. **Save/Load Preset** — INI-based preset save/load per effect type (using typed `getINISetting` reads, not `execute()`).
3. **Undo support** — wrap the generated MaxScript in a `theHold.Begin()` / `theHold.Accept()` block so the artist can Ctrl-Z the entire tyFlow creation.
4. **Scene validation** — before generating, check that tyFlow plugin is loaded (`classof (particleFlowMod()) != UndefinedClass` or similar); show a clear error if not.

**Refer to:** `tyflow_scripts/server/tyfx.py` for the MaxScript generation backend. The UI changes are in `tyflowFXLauncher.ms` only; `tyfx.py` accepts keyword arguments for the new parameters.

---

### 5.6 Remaining Standard Sub-Tasks (from master plan)

These sub-tasks from `soulburn-2027-update-plan.md` are not yet confirmed complete:

| Sub-Task | Status | Description |
|---|---|---|
| Sub-Task 2: Remove Obsolete Scripts | Not confirmed | Delete/archive 10 scripts that are now native in Max 2025+ |
| Sub-Task 3: Fix VRay Scripts | Not confirmed | Update `vraySamplingSubdivManager.ms`, `vrayMatteManager.ms` for V-Ray 6/7 |
| Sub-Task 4: Fix Camera Scripts | Not confirmed | Add Physical Camera output to `cameraFromPerspView.ms`, `cameraLensPackager.ms` |
| Sub-Task 13: Code Quality Pass | Partial | Fix all 87 scripts: typed INI reads, no Brazil/MR literals, `sLibGetSafeUIPos`, struct state containers |

The full todo lists for each sub-task are in `soulburn-2027-update-plan.md` §Sub-Tasks.

---

## 6. Architecture & Conventions

### 6.1 Script Anatomy (every .ms file)
```maxscript
-- ── Script: scriptName.ms ──────────────────────────────────────────────────
-- v2.00 | Tested: 3ds Max 2027
-- Requires: sLib.ms v2.00+
-- UI: scriptNameUI macro in SoulburnScripts.mcr
fileIn (getDir #scripts + "\\SoulburnScripts\\lib\\sLib.ms")

struct scriptNameState ( field1 = default1, field2 = default2 )
global _scriptNameState = scriptNameState()

fn scriptNameDefault = ( ... )
fn scriptNameUI      = ( createDialog scriptNameRollout ... )
```

### 6.2 INI Reads — Typed Only (no `execute`)
```maxscript
-- CORRECT (v2.0):
myInt   = (getINISetting f s k) as integer
myFloat = (getINISetting f s k) as float
myBool  = (getINISetting f s k) == "true"
myArr   = filterString (getINISetting f s k) ","

-- WRONG (v1.x — never use):
myVar = execute(getINISetting f s k)
```

### 6.3 UI Positioning — Dynamic
```maxscript
local pos = sLibGetSafeUIPos 300 200
createDialog rolloutName width:300 height:200 pos:pos
```

### 6.4 Atlas Bridge Call Pattern
```maxscript
-- sLibAtlasBridgeCall(cmdName, paramsObj) is available in sLib.ms v2.00
local result = sLibAtlasBridgeCall "set_keys" #(#("node","Atlas_Cam"), #("keys", keyArray))
```

### 6.5 Icon Naming Convention
```
UI_ln/Icons/SoulburnScripts_{ScriptName}_{SIZE}{state}.bmp
  SIZE  = 16 or 24
  state = a (active) or i (inactive)
Example: SoulburnScripts_arnoldMaterialManagerUI_24a.bmp
```

### 6.6 MCR Registration Pattern
```maxscript
macroScript arnoldMaterialManager
category:"SoulburnScripts"
icon:#("SoulburnScripts_arnoldMaterialManager", 1)
buttonText:"Arnold Mat Manager"
tooltip:"Arnold Material Manager"
(
    fileIn (getDir #scripts + "\\SoulburnScripts\\scripts\\arnoldMaterialManager.ms")
    arnoldMaterialManagerDefault()
)
```

### 6.7 Python Execution from MaxScript
```maxscript
-- Direct file execution:
python.ExecuteFile (getDir #scripts + "\\SoulburnScripts\\lib\\atlas\\start_bridge.py")

-- Temp file pattern (for parameter injection):
local tmp = (getDir #temp) + "\\sb_run.py"
local f   = openFile tmp mode:"w"
format "# auto-generated\n" to:f
close f
python.ExecuteFile tmp
```

---

## 7. New Features — Detailed Specs

### 7.1 MaxMaze Generator

**Deliverables:** `max_maze.py` → copied to `SB2027/scripts/SoulburnScripts/lib/maze/max_maze.py`; new `maxMazeGenerator.ms` UI wrapper.

**Source algorithm:** Recursive back-tracker (`_backtracker`), optional braiding (`_braid`), Editable Poly face-adjacency graph, edge selection + face extrusion.

**Parameters to expose in UI:**
| Parameter | Type | Default | Range |
|---|---|---|---|
| Seed | integer | 42 | any |
| Braid | float | 0.0 | 0.0–1.0 |
| Wall Depth | float | 2.0 | 0.0–1000.0 |
| Wall Width | float | 0.3 | 0.0–0.5 |

**Known limitation:** O(edges) face lookup — performance note in source for meshes >10k faces.

**Icon:** Recommend a small grid with some interior edges removed (open maze corridors).

---

### 7.2 Custom Lighting Assistant

**Source:** `C:\Users\mabdu\Downloads\scripts\COURSE-WEEK-3.md` (Week 3 — 3D Lighting Course by Iván M. Benítez Sanz).

**Key concepts to implement:**

1. **GI control** — bounce count per renderer; note that noise originates from indirect lighting samples.
2. **Fake bounce fill** — light spread = 1, no specular, colour-matched to subject surface; positioned opposite key.
3. **AOV setup** — Diffuse, Specular, SSS, Emission/Volume, Z-depth, Position (Pref variant), UVs, Normals, Beauty, Light Groups.
4. **Light Group AOVs** — per-light group label (e.g. `key`, `fill`, `rim`); creates `RGBA_{group}` and `Diffuse_{group}` AOVs.
5. **Light Filters (Arnold only):** Light Blocker (bounding-box-based occlusion), Light Decay (near/far fade, quadratic falloff as default), Gobo (slide map, density, filter mode), Barndoor (spot-only, four fin angles).

**Renderer detection:** Use `sLibWhatsCurrentRenderer()` to show/hide renderer-specific sections.

---

### 7.3 tyFlow FX Launcher Improvements

**File to modify:** `SB2027/scripts/SoulburnScripts/scripts/tyflowFXLauncher.ms`
**Backend:** `tyflow_scripts/server/tyfx.py` (accepts keyword args)

**New parameters per effect:** See §5.5 table above.

**New UI features:** Dry Run mode, INI preset save/load, undo block wrapping (`theHold.Begin/Accept`), plugin presence validation.

---

## 8. Files to Read Before Starting

Before implementing any new work, read these files in order:

1. **`soulburn-2027-update-plan.md`** — complete master spec.
2. **`SB2027/CHANGELOG.md`** — confirms what is done.
3. **`SB2027/scripts/SoulburnScripts/lib/sLib.ms`** — shared library, understand all v2.00 additions.
4. **`SB2027/MacroScripts/SoulburnScripts.mcr`** — macro registration syntax.
5. **`C:\Users\mabdu\Downloads\scripts\max_maze.py`** — MaxMaze source to integrate.
6. **`C:\Users\mabdu\Downloads\scripts\COURSE-WEEK-3.md`** — lighting course source for the lighting assistant.
7. **`tyflow_scripts/server/tyfx.py`** — tyFlow script generator backend.
8. **`SB2027/scripts/SoulburnScripts/scripts/tyflowFXLauncher.ms`** — existing tyFlow UI to extend.
9. **`SB2027/scripts/SoulburnScripts/scripts/atlasBridgeLauncher.ms`** — Atlas launcher pattern to follow.

---

## 9. Suggested Skills for Next Agent

Activate the following skills at the start of the next session:

| Skill | When to Use |
|---|---|
| `writing-plans` | Before implementing any new script — write a plan first. |
| `implement` | When executing the implementation plan for each new script. |
| `matlab` | If any signal-processing or numerical logic arises in the lighting assistant math. |
| `architecture-diagram` | To produce a visual overview of how the toolbar, installer, and script registry interact. |
| `systematic-debugging` | If MaxScript or Python integration errors occur. |
| `diagnosing-bugs` | When scripts produce unexpected results in Max (runtime errors, silent failures). |
| `ponytail` | To avoid over-engineering — keep scripts minimal and direct. |
| `code-review` | After completing a batch of scripts, before marking done. |
| `verification-before-completion` | Before claiming any sub-task is complete — run in Max sandbox first. |
| `docx` | If end-user documentation needs to be produced in Word format. |

---

## 10. Session Constraints & Notes

- **Platform:** Windows 10 (`win32`, `x64`). Shell is PowerShell 5.1.
- **3ds Max version target:** 2025–2027 (primary), 2020+ (minimum supported).
- **Python target:** 3.10+ (Max 2025 ships Python 3.10; Max 2027 ships Python 3.11).
- **No external Python dependencies** for the MaxScript-level scripts — all Python used via `python.ExecuteFile` into Max's embedded interpreter.
- **Bridge dependencies** (Atlas only): `PySide6`, `fastmcp`, `pandas`, `shapely` — installed via installer or manually.
- **No Redshift support** — deferred to v2.x.
- **No game-engine features** — out of scope.
- **INI presets must NOT use `execute()`** — typed reads only (see §6.2).
- **Window positioning must use `sLibGetSafeUIPos`** — no hardcoded `[400,400]`.
- **State containers must be structs** — no bare globals.
- **Icon files MUST be BMP** — 16×16 and 24×24, light and dark variants. 4 files minimum per script action.
- The workspace root (`c:\Users\mabdu\Downloads\SoulburnScriptsPack_3dsMax_v112_R2013toR2022`) contains multiple git repos (`cinematic_cameras/`, `max_mcp_server/`, `tyflow_scripts/` each with their own `.git`).
- `C:\Users\mabdu\Downloads\scripts\` is an external scripts folder outside the workspace — contains `max_maze.py` and `COURSE-WEEK-3.md`.

---

## 11. Quick Command Reference

```powershell
# Find all execute(getINISetting) calls still needing fixing:
Select-String -Path "SB2027\scripts\SoulburnScripts\scripts\*.ms" -Pattern 'execute\(getINISetting'

# Find all hardcoded [400,400] positions:
Select-String -Path "SB2027\scripts\SoulburnScripts\scripts\*.ms" -Pattern '\[400,400\]'

# List scripts missing IconDark entries:
Get-ChildItem "SB2027\scripts\SoulburnScripts\scripts\*.ms" | ForEach-Object {
    $n = $_.BaseName
    if (-not (Test-Path "UI_ln\IconsDark\SoulburnScripts_${n}_16a.bmp")) { $n }
}

# Run pytest for tyflow_scripts:
cd tyflow_scripts; python -m pytest tests -q

# Run pytest for max_mcp_server:
cd max_mcp_server; python -m pytest tests -q
```

---

## 12. Known Issues / Watch-Outs

1. **`SoulburnScripts.cuix`** — the toolbar state file currently exists at `SB2027/MacroScripts/SoulburnScripts.cuix` but may not include all 9 new script buttons. Verify it includes entries for all tools before the installer copies it.
2. **`layerCleaner.ms`** — version check boundary has not been confirmed fixed (`< 18.0` should be `<= 17.0`). Audit before marking Sub-Task 13 complete.
3. **`texmapBaker.ms`** — RTT (Render to Texture) API changed in Max 2022. This is in the "needs update" list but no fix has been merged yet.
4. **`parameterManager.ms`** — documented as needing a full parameter access audit (last tested on Max 2011). Do not mark as clean until tested on Max 2025.
5. **`tyfx.py` parameter names** — all names were read from a live 3ds Max 2027 + V-Ray 7 Update 3 instance. On other versions, treat as unverified (per `tyflow_scripts/README.md`).
6. **Icon generation at scale** — generating 4 BMP variants for 11+ new scripts = 44+ new image files. Use a Python `Pillow` script to automate this. Coordinate naming exactly with `SoulburnScripts.mcr` icon references.
7. **Floating toolbar `.cuix` approach** — if Max ignores a copied `.cuix` on startup, the fallback is to use `soulburnToolbarAutoCreate.ms` with direct `cui.createToolbar` calls in a startup script. Test both approaches.

---

*End of handoff document.*
