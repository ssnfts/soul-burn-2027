# SoulBurn Scripts Pack v2.0 — Next-Session Handoff Document

> **For the next agent:** This document is your full context for continuing the SoulBurn Scripts Pack v2.0 project for 3ds Max 2025–2027. Read every section before writing a single line of code. Do not skip the Architecture & Conventions section — violating those rules has broken the toolchain in previous sessions.
>
> **ACTIVATE THESE SKILLS FIRST** (before doing anything else):
> - `writing-plans` — before implementing any new script
> - `implement` — when executing each plan
> - `systematic-debugging` — when MaxScript or Python integration breaks
> - `ponytail` — to avoid over-engineering
> - `verification-before-completion` — before claiming any sub-task is done

---

## 1. Project Goal

Ship **SoulBurn Scripts Pack v2.0 for 3ds Max 2025–2027** — a community-maintained update of Neil Blevins' SoulBurn Scripts Pack v1.12. The pack contains 91+ `.ms` scripts, a floating toolbar with unique per-button icons, an EXE installer, and several new power tools (Smart Lighting, MaxMaze, Custom Lighting Assistant, tyFlow FX improvements, Atlas MCP bridge).

**Current blocker:** Every button in the floating toolbar renders as a blank white square because all BMP icon files contain only white pixels. This must be resolved before anything else is demo-able.

---

## 2. Repository Layout

```
c:\Users\mabdu\Downloads\SoulburnScriptsPack_3dsMax_v112_R2013toR2022\   ← workspace root
├── SB2027/                        ← PRIMARY working directory
│   ├── MacroScripts/
│   │   ├── SoulburnScripts.mcr          206 macros registered
│   │   └── SoulburnScripts.cuix         toolbar layout (223 items = 206 buttons + 17 separators)
│   ├── scripts/
│   │   ├── Startup/
│   │   │   ├── SoulburnScripts_ToolbarAutoCreate.ms
│   │   │   └── SoulburnScripts_AtlasAutoStart.ms
│   │   └── SoulburnScripts/
│   │       ├── lib/
│   │       │   ├── sLib.ms                  ← v2.00, global sLibGetINI* declared at line 335
│   │       │   ├── smart_lighting_ui.py     ← PySide6 panel (BUILD/AUDIT/PASSES tabs)
│   │       │   ├── tyfx.py                  ← tyFlow script generator backend
│   │       │   ├── raceanim.py              ← CrashSpec for debris/sparks
│   │       │   ├── cinecam.py               ← Cinematic camera move algorithms
│   │       │   ├── atlas/
│   │       │   │   ├── atlas_max_bridge.py  ← PySide6 removed; uses tickCallback
│   │       │   │   ├── atlas_max_handlers.py
│   │       │   │   └── start_bridge.py
│   │       │   └── maze/
│   │       │       └── max_maze.py          ← Recursive back-tracker maze on Editable Poly
│   │       └── scripts/
│   │           ├── (91 .ms script files)
│   │           ├── maxMazeGenerator.ms      ← EXISTS but needs icon + MCR entry audit
│   │           ├── customLightingAssistant.ms ← EXISTS (4 rollouts: GI, AOV, Groups, Filters)
│   │           ├── tyflowFXLauncher.ms      ← v2.00 rewrite, needs tyFlow improvements
│   │           ├── smart_lighting.ms        ← EXISTS, PySide6 panel launcher
│   │           └── uninstall_soulburn.ms    ← EXISTS
│   ├── installer/
│   │   ├── installer.py             703 lines, Uninstall tab present
│   │   └── build_installer.py       cx_Freeze, Python 3.12
│   ├── installer_dist/
│   │   ├── SoulburnScripts_v2_Setup.exe   ← 29.1 MB bundle (GITIGNORED)
│   │   └── README.md
│   ├── tools/
│   │   ├── make_cuix.py             ← regenerates SoulburnScripts.cuix from GROUPS list
│   │   └── make_smart_icons.py      ← BROKEN: generates white-only BMPs
│   └── UI_ln/
│       ├── Icons/                   ← 1213+ BMP files, SoulburnScripts_name_SIZEstate.bmp
│       └── IconsDark/               ← dark theme variants
│
├── UI_ln/                           ← ROOT-LEVEL icon store (legacy originals from v1.12)
│   ├── Icons/
│   └── IconsDark/
│
├── cinematic_cameras/               ← separate git repo
├── max_mcp_server/                  ← separate git repo
├── tyflow_scripts/                  ← separate git repo
│   └── server/
│       └── tyfx.py                  ← tyFlow backend (READ THIS before touching tyflowFXLauncher.ms)
│
├── HANDOFF.md                       ← previous handoff (still valid, this doc supersedes it)
├── TASK_LOG.md                      ← full session-by-session history of all decisions
├── COURSE-WEEK-3.md                 ← lighting course source for customLightingAssistant.ms
└── soulburn-2027-update-plan.md     ← master spec (read before implementing any sub-task)

INSTALLED (live 3ds Max ENU directory):
C:\Users\mabdu\AppData\Local\Autodesk\3dsMax\2027 - 64bit\ENU\
├── scripts\SoulburnScripts\          ← 91 .ms files
├── usermacros\SoulburnScripts.mcr
├── UI_ln\Icons\SoulburnScripts_*    ← 1213 BMP files (ALL WHITE PIXELS — see §4.1)
├── UI_ln\SoulburnScripts.cuix
└── scripts\Startup\
    └── SoulburnScripts_ToolbarAutoCreate.ms

EXTERNAL FILES (outside workspace — referenced by tasks):
C:\Users\mabdu\Downloads\scripts\
├── max_maze.py          ← original (unguarded run_maze() at bottom — has been fixed in lib/maze/)
└── COURSE-WEEK-3.md     ← lighting course notes (already encoded in customLightingAssistant.ms)
```

---

## 3. Current Status: What Is Done vs What Is Broken

### 3.1 Committed and Deployed (HEAD: `821948f` on `ssnfts/soul-burn-2027`)

| Area | Status |
|------|--------|
| 91 `.ms` scripts, all `$scripts` → `$userScripts` fixed | ✅ Done |
| `sLib.ms` v2.00 (7 `sLibGetINI*` globals, `sLibGetSafeUIPos`, renderer detection) | ✅ Done |
| `SoulburnScripts.mcr` with 206 macros | ✅ Done |
| `SoulburnScripts.cuix` with 223 items (206 buttons + 17 separators) | ✅ Done |
| `soulburnToolbarAutoCreate.ms` (toolbar auto-creates on first Max launch) | ✅ Done |
| `smart_lighting.ms` + `smart_lighting_ui.py` | ✅ Done |
| `uninstall_soulburn.ms` | ✅ Done |
| `maxMazeGenerator.ms` (MaxScript wrapper for max_maze.py) | ✅ Done |
| `customLightingAssistant.ms` (4 rollout tabs: GI, AOV, Groups, Filters) | ✅ Done |
| `tyflowFXLauncher.ms` v2.00 (spine picker, dry run, undo block) | ✅ Done |
| Atlas bridge PySide6 crash fixed (replaced QTimer with tickCallback) | ✅ Done |
| Substance `SubstanceDialog.py` import error fixed | ✅ Done |
| EXE installer (cx_Freeze, `SoulburnScripts_v2_Setup.exe`) | ✅ Done |

### 3.2 BROKEN / Not Yet Done (Ordered by Priority)

#### PRIORITY 1 — Icons Are All White (BLOCKING)
Every BMP in `UI_ln/Icons/` and `UI_ln/IconsDark/` produces white/blank buttons in 3ds Max. The pixel data at offset 54 is `FF FF FF FF ...` (white) for ALL files — both original Neil Blevins icons AND the newly generated ones.

**Root cause (most likely):** The Pillow `img.save(buf, "BMP")` call stores the image top-to-bottom (standard BMP coordinate system requires bottom-to-top). When Max reads the file it may see the image mirrored and the gradient background (near-white at top) fills the icon. Alternatively, the `factor` calculation in `_make_background()` produces near-white values even for non-white base colours.

**Key diagnostic:** The `_make_background` function uses `factor = (0.51 + (1.0 - t) * 0.09) * mul`. For amber `(245, 158, 11)`:
- `clamp(245 * 0.60) = 147` — not white. So the pixel data IS coloured in theory.
- But Pillow BMP saves as bottom-up by default, meaning row 0 written first = top of image in Max.
- Sampling only "first 8 pixels" reads from BMP file offset 54 = the LAST row of a bottom-up BMP = the row that corresponds to the BOTTOM of the displayed image. For a top-lit gradient this is the DARKEST row, not white.
- **The icon data is almost certainly correct. The sampling test was misleading.**

**Immediate action required:**
1. Open one BMP (`SoulburnScripts_smartLighting_16a.bmp`) in any image viewer. If it shows a coloured gradient — the files are fine, the problem is deployment (icons not reaching the live ENU directory).
2. If the image viewer shows a white square — the Pillow save is wrong. Check whether `_make_background` actually draws non-white pixels by running `make_smart_icons.py` and printing the RGB value of pixel `(8, 8)`.
3. Also confirm whether the generated files are being copied to the correct live ENU path during installer runs.

**Unique custom icons needed for ALL new scripts (see full list in §4.2 below).**

#### PRIORITY 2 — Floating Toolbar Post-Installation Auto-Show
After the installer runs, 3ds Max should show the SoulBurn floating toolbar automatically on first launch, without the user needing to go to Customize → Toolbars → drag buttons. `soulburnToolbarAutoCreate.ms` exists but the auto-creation logic needs auditing — verify `cui.loadConfig` / `cui.showToolbar` / `cui.saveConfig` calls are present and the `Created=1.0` INI flag reset forces a rebuild. See §5 Task 2 for full spec.

#### PRIORITY 3 — MaxMaze Custom UI (icon + MCR audit)
`maxMazeGenerator.ms` exists and works, but:
- Its icon does not exist in `UI_ln/Icons/` (white blank button)
- The external `C:\Users\mabdu\Downloads\scripts\max_maze.py` has a **different version** from `SB2027/scripts/SoulburnScripts/lib/maze/max_maze.py` — the original has an **unguarded `run_maze()` at the bottom** (line 203) while the lib version correctly uses `if __name__ == "__main__"`. Ensure the lib version is what the installer deploys.
- Need to verify the MCR entry for `maxMazeGenerator` uses `Icon:#("SoulburnScripts_maxMazeGenerator", 1)`.

#### PRIORITY 4 — Custom Lighting Assistant (icon + enhancements)
`customLightingAssistant.ms` exists and implements all 4 rollouts from `COURSE-WEEK-3.md`. Missing:
- Icon files for `customLightingAssistant` and `customLightingAssistantUI`
- Enhancement: Add a 5th rollout "Lighting Theory Tips" with a scrollable label quoting the 10 photorealism principles from `COURSE-WEEK-3.md` (Points 1–10). This makes the tool self-documenting for artists.
- Enhancement: Add the Three Photographic Constraints from Point 8 as tooltip text on the "Add Bounce Fill Light" button.

#### PRIORITY 5 — tyFlow FX Launcher Improvements
`tyflowFXLauncher.ms` v2.00 has dry run, undo block, and spine picker. Still missing from the v2.00 UI:
- **Per-wheel toggles** (FL/FR/RL/RR checkboxes) for tyre smoke — `tyfx.py` accepts `emitter_nodes` as a list; the UI currently takes a comma-separated string.
- **Smoke colour gradient picker** — `tyfx.py` API supports a `smoke_colour` parameter; this is not surfaced in the UI.
- **Debris size min/max** — `tyfx.py` accepts `debris_size_min`, `debris_size_max` — not surfaced.
- **Spark colour gradient** — `tyfx.py` may accept `spark_colour_hot`, `spark_colour_cool` — check the actual `tyfx.py` signature in `tyflow_scripts/server/tyfx.py` before adding (do NOT add dead controls if the param does not exist).
- **Rain/Dust/Fire effects** — `tyfx.py` provides `write_rain_script`, `write_dust_script`, `write_fire_script` (spine-free). Add tabs for these three effects.

---

## 4. Key Technical Details

### 4.1 Icon System — Exact Binary Layout

Max reads icons as 24-bit uncompressed BMP files:
- Header size: 54 bytes (14 BMP header + 40 DIB header)
- No colour table
- Pixel data starts at offset 54
- Rows are stored bottom-up (BMP standard)
- File sizes: 16×16 → 824 bytes, 24×24 → 1784 bytes
- `img_size` field = `(rows × stride) + 2` where `stride = ceil(W×3/4)×4`
- `xppm = yppm = 2834` (72 dpi in pixels per metre)
- 2-byte `0x00 0x00` GDI null terminator appended after pixel data
- Icon filename pattern: `SoulburnScripts_{scriptName}_{size}{state}.bmp`
  - `size` = `16` or `24`
  - `state` = `a` (active/coloured) or `i` (inactive/greyed)
- Same four files must exist in BOTH `UI_ln/Icons/` and `UI_ln/IconsDark/`
- MCR registration: `Icon:#("SoulburnScripts_scriptName", 1)` — the integer `1` selects icon index 1 from the BMP strip (our files each contain one icon, so always `1`)

**Scripts completely missing icon sets (must be created):**
```
arnoldMaterialManager     arnoldMaterialManagerUI
coronaMaterialManager     coronaMaterialManagerUI
physicalCameraManager     physicalCameraManagerUI
oslMapBrowser             oslMapBrowserUI
gltfExportHelper          gltfExportHelperUI
cinematicCameraMaker      cinematicCameraMakerUI
tyflowFXLauncher          tyflowFXLauncherUI
atlasBridgeLauncher       atlasBridgeLauncherUI
atlasCineSceneBuilder     atlasCineSceneBuilderUI
maxMazeGenerator          maxMazeGeneratorUI
customLightingAssistant   customLightingAssistantUI
smartLighting             smartLightingUI
uninstallSoulburn         (no UI variant — just one icon needed)
materialMoverCleanMeditVrayMtl  (variant macro — just one icon needed)
```

**Suggested icon glyphs (unique, not generic gear/star):**
| Script | Glyph Design | Colour |
|--------|-------------|--------|
| `arnoldMaterialManager` | Orange sphere (Arnold icon) | `#E07820` |
| `coronaMaterialManager` | Blue flame outline | `#2563EB` |
| `physicalCameraManager` | Aperture iris (6 blades) | `#64748B` |
| `oslMapBrowser` | Sine wave with a node circle | `#8B5CF6` |
| `gltfExportHelper` | Right-pointing arrow with 3 dots | `#10B981` |
| `cinematicCameraMaker` | Clapperboard outline | `#F59E0B` |
| `tyflowFXLauncher` | Particle burst (5 lines from centre) | `#EF4444` |
| `atlasBridgeLauncher` | Two connected hexagons (network) | `#06B6D4` |
| `atlasCineSceneBuilder` | Film frame with buildings | `#7C3AED` |
| `maxMazeGenerator` | 3×3 grid with interior edges removed | `#16A34A` |
| `customLightingAssistant` | Light bulb with 3 concentric ring marks | `#FBBF24` |
| `smartLighting` | 3-point triangle + sun apex | `#F59E0B` |
| `uninstallSoulburn` | Bold ✕ inside a circle | `#EF4444` |
| `materialMoverCleanMeditVrayMtl` | V-Ray "V" letterform | `#1D4ED8` |

**Icon generation tool:** `SB2027/tools/make_smart_icons.py` — currently only generates 4 tools. Extend it to all 14 missing scripts using the same `make_icon()` / `save_bmp_exact()` pattern. Run it from the workspace root: `python SB2027/tools/make_smart_icons.py`.

### 4.2 Architecture Constraints (Never Violate These)

```
RULE 1: Never use $scripts in include paths — always $userScripts
   WRONG:  include "$scripts\SoulburnScripts\lib\sLib.ms"
   RIGHT:  include "$userScripts\SoulburnScripts\lib\sLib.ms"

RULE 2: Never use execute(getINISetting ...) — typed reads only
   WRONG:  myVar = execute(getINISetting file section key)
   RIGHT:  myInt = sLibGetINIInteger file section key defaultVal
   RIGHT:  myFloat = sLibGetINIFloat file section key defaultVal
   RIGHT:  myStr = sLibGetINIString file section key defaultVal
   RIGHT:  myBool = sLibGetINIBoolean file section key defaultVal
   RIGHT:  myPt2 = sLibGetINIPoint2 file section key (sLibGetSafeUIPos w h)
   RIGHT:  myPt3 = sLibGetINIPoint3 file section key [0,0,0]

RULE 3: Never hardcode UI positions — always use sLibGetSafeUIPos
   WRONG:  createDialog rollout pos:[400,400]
   RIGHT:  local pos = sLibGetSafeUIPos 300 200
           createDialog rollout pos:pos

RULE 4: Never use PySide6 / Qt timers in scripts loaded by Max at startup
   The Qt DLL binding fails in Max 2027 (Python 3.13). If you need a timer,
   use: pymxs.runtime.callbacks.addScript(#tickCallback, ...)

RULE 5: Python execution from MaxScript uses temp file pattern
   local tmp = (getDir #temp) + "\\sb_run.py"
   local f = openFile tmp mode:"w"
   format "# auto-generated\n" to:f
   close f
   python.ExecuteFile tmp
   (always delete the temp file after: try (deleteFile tmp) catch ())

RULE 6: Every .ms script must declare globals at the top before the include block
   Example pattern (see maxMazeGenerator.ms for reference):
   global maxMazeGeneratorDefaults
   global maxMazeGeneratorUI
   global mMGFloater
   include "$userScripts\SoulburnScripts\lib\sLib.ms"
```

### 4.3 sLib.ms v2.00 Functions Available

The following helpers are declared `global` at line 335 of `sLib.ms` and are safe to call from any script after the `include` line:

| Function | Signature | Notes |
|----------|-----------|-------|
| `sLibGetINIInteger` | `(filename section key default)` | Returns integer |
| `sLibGetINIFloat` | `(filename section key default)` | Returns float |
| `sLibGetINIString` | `(filename section key default)` | Returns string |
| `sLibGetINIBoolean` | `(filename section key default)` | Returns true/false |
| `sLibGetINIPoint2` | `(filename section key default)` | Returns Point2 |
| `sLibGetINIPoint3` | `(filename section key default)` | Returns Point3 |
| `sLibGetINIColor` | `(filename section key default)` | Returns Color |
| `sLibGetSafeUIPos` | `(width height)` | Returns Point2 safe for screen bounds |
| `sLibWhatsCurrentRenderer` | `()` | Returns `"arnold"`, `"vray"`, `"corona"`, or `"scanline"` |
| `sLibFileExist` | `(path)` | Returns boolean; wraps doesFileExist safely |

### 4.4 MCR Registration Pattern

Every script requires TWO macro entries in `SoulburnScripts.mcr`:
```maxscript
-- Default action (left-click)
MacroScript maxMazeGenerator category:"SoulburnScripts" tooltip:"maxMazeGenerator" Icon:#("SoulburnScripts_maxMazeGenerator",1)
    (
    Include "$userScripts/SoulburnScripts/scripts/maxMazeGenerator.ms"
    on execute do maxMazeGeneratorDefaults()
    on Altexecute type do maxMazeGeneratorUI()
    )

-- UI variant (explicit UI launcher)
MacroScript maxMazeGeneratorUI category:"SoulburnScripts" tooltip:"maxMazeGeneratorUI" Icon:#("SoulburnScripts_maxMazeGeneratorUI",1)
    (
    Include "$userScripts/SoulburnScripts/scripts/maxMazeGenerator.ms"
    maxMazeGeneratorUI()
    )
```

Both macros must also appear in `SoulburnScripts.cuix` (generated by `make_cuix.py`). After adding new macros, always re-run `python SB2027/tools/make_cuix.py` to rebuild the `.cuix`.

### 4.5 MaxMaze — Two Versions in Play

| File | State | Used By |
|------|-------|---------|
| `C:\Users\mabdu\Downloads\scripts\max_maze.py` | **Original** — has `run_maze()` at module bottom (unguarded, fires on import) | User reference only |
| `SB2027/scripts/SoulburnScripts/lib/maze/max_maze.py` | **Fixed** — guarded with `if __name__ == "__main__"`, `run_maze()` returns `(passages, wall_faces)` tuple | Deployed by installer |

The `maxMazeGenerator.ms` wrapper uses `importlib.util.spec_from_file_location` to import the lib version and call `mod.run_maze(seed=..., braid=..., depth=..., wall_width=...)`. The result is stored in `rt.mMGLastResult` as a string.

**Critical difference from the original:** The original `_backtracker()` calls `random.seed(SEED)` internally at the top — making it ignore the `seed` parameter passed to `run_maze()`. The lib version **does not** re-seed inside `_backtracker()`; instead `run_maze()` calls `random.seed(seed)` before calling `_backtracker()`. This is the correct behaviour.

### 4.6 Custom Lighting Assistant — Source Knowledge

The `customLightingAssistant.ms` was built from `COURSE-WEEK-3.md`. The key concepts already implemented:

| Course Concept | Implementation |
|----------------|---------------|
| GI noise from indirect samples → fake bounces to lower sample counts | `cLAAddBounceLight()` — creates Omni light, no specular, spread = 1 |
| Bounce light has no directionality → spread forced to 1 | `L.contrast = 0; L.softenDiffuseEdge = 100` |
| AOVs (Diffuse, Specular, SSS, Emission, Depth, Position, UVs, Normals) | `cLAEnableAOVs()` — renderer-aware via `sLibWhatsCurrentRenderer()` |
| Light Groups = per-light AOVs | `cLAAssignLightGroup()` — sets `aiAovLightGroupPrefix` (Arnold), `effectID` (Corona), or user property fallback |
| Light Filters (Gobo, Barndoor, Decay, Blocker) | `cLAAddLightFilter(#gobo/#barndoor/#decay/#blocker)` — Arnold-only, Gobo/Barndoor spot-only |
| Merge AOVs into single EXR | `cLAMergeEXRValue` checkbox + `rem.SetElementsActive true` |

**What still needs to be added to `customLightingAssistant.ms`:**
1. **Lighting Theory Tips rollout** — 5th collapsible rollout displaying Points 1–10 from COURSE-WEEK-3.md as read-only label text, so artists have the theory in-context.
2. **Three Photographic Constraints** (from Point 8) added as a tooltip or a modal "Notes" dialog:
   - "Avoid adding too many lights without a scheme"
   - "Do not light with invisible lights"
   - "Do not overly alter the sunlight"
3. **Renderer status in every rollout's `on open`** — currently only the GI rollout shows the renderer name. Add the same label to AOV and Groups rollouts.

### 4.7 tyFlow FX Launcher — Architecture

The `tyflowFXLauncher.ms` works as follows:
1. Artist picks a circuit spline (shape node in scene) using `pickbutton`
2. `tFXSpineLiteral` reads all knots from the spline and builds a Python `[(x,y),...]` string
3. `tFXGenerate(#smoke|#debris|#sparks)` writes a temp `.py` file that imports `tyfx.py` via `sys.path.insert` and calls the appropriate `write_*_script()` function
4. The generated MaxScript (`.ms`) is written to `%TEMP%\sb_tyfx_smoke.ms` etc
5. `tFXRunGenerated(path)` prompts the artist to review then `fileIn`s the script inside a `theHold.Begin/Accept` block

**Important:** `tyfx.py` is in `tyflow_scripts/server/tyfx.py` (a SEPARATE git repo). Before adding new parameters to the tyFlow UI, verify the actual function signatures in that file. The `tFXNodeListLiteral()` helper converts `"node1, node2"` strings to Python list literals `['node1','node2']`.

---

## 5. Prioritised Implementation Plan for Next Session

### Task 1 — Fix Icons (MUST DO FIRST)

**Files to modify:** `SB2027/tools/make_smart_icons.py`
**Files to create:** New icon generation functions for 14 missing script icon sets
**Deploy to:** `UI_ln/Icons/`, `UI_ln/IconsDark/`, AND `C:\Users\mabdu\AppData\Local\Autodesk\3dsMax\2027 - 64bit\ENU\UI_ln\Icons\`

**Exact steps:**
1. Run `python SB2027/tools/make_smart_icons.py` and open one output file (e.g. `UI_ln/Icons/SoulburnScripts_smartLighting_16a.bmp`) in Windows Photo Viewer. If it shows a coloured icon — the generator is CORRECT and the issue is deployment (files not reaching ENU). If it shows white — the generator is BROKEN.
2. If broken: the fix is to add `img = img.transpose(Image.FLIP_TOP_BOTTOM)` before saving — Pillow saves top-down but BMP spec is bottom-up. Alternatively, use `img.save(buf, "BMP")` which Pillow handles correctly for BMP (it already flips). Add a debug print of `img.getpixel((8, 8))` to confirm non-white pixel before saving.
3. Extend `make_smart_icons.py` with draw functions for all 14 missing scripts (see glyph design table in §4.1). Each draw function follows the same pattern as `draw_lighting()` and `draw_uninstall()` — takes `(draw, size, inactive)` arguments, draws white glyphs on the background.
4. After generation, copy the new BMPs to the ENU Icons directory.

**Do NOT use external image libraries beyond Pillow — it is already used.**

### Task 2 — Floating Toolbar Post-Installation Auto-Show

**Files to modify:** `SB2027/scripts/SoulburnScripts/scripts/soulburnToolbarAutoCreate.ms`, `SB2027/installer/installer.py`

**Exact implementation:**
- `soulburnToolbarAutoCreate.ms` should check `Created` flag in `{plugcfg}\SoulburnScripts\SoulburnScripts.ini`. If not present or not `1.0`, run `cui.loadConfig` then `cui.showToolbar "SoulburnScripts"` then set the flag.
- The `.cuix` file must be copied by the installer to BOTH `{ENU}\UI_ln\SoulburnScripts.cuix` AND `{ENU}\en-US\plugcfg\SoulburnScripts.cuix` (Max reads from both paths depending on version).
- After installation the toolbar should float at a sensible position — use `cui.setToolbarPosition "SoulburnScripts" 100 100` or equivalent.

### Task 3 — MaxMaze Custom UI Enhancements

**File:** `SB2027/scripts/SoulburnScripts/scripts/maxMazeGenerator.ms` (exists, needs icon + one enhancement)

**Enhancement:** Add a **"Random Seed"** button next to the seed spinner that calls `random 0 99999` and updates `mMGSeedSpinner.value`. This lets artists explore different mazes in one click. The MaxScript `random` function takes `(min max)` — use `(random 0 99999)`.

**Icon generation:** Add `maxMazeGenerator` glyph to `make_smart_icons.py` using the grid motif described in §4.1.

### Task 4 — Custom Lighting Assistant Enhancements

**File:** `SB2027/scripts/SoulburnScripts/scripts/customLightingAssistant.ms` (exists, needs 2 additions)

**Addition 1 — Lighting Theory Tips rollout:**
Add a 5th rollout `cLARolloutTips "Lighting Theory Tips"` (starts rolled up). Body is a multiline label showing the 10 photorealism principles from `COURSE-WEEK-3.md`. Use MaxScript `label` controls with `align:#left` and explicit `offset` to lay out text. The rollout header should read "10 Principles of Photorealistic Lighting".

**Addition 2 — Three Constraints tooltip:**
Modify the `cLABounceButton` tooltip (or add a `label cLAConstraintsNote` under it) to show: `"Rule: 1 scheme → 1 key light. Never invisible lights. Never alter sunlight."`.

### Task 5 — tyFlow FX Launcher: Rain / Dust / Fire Tabs

**File:** `SB2027/scripts/SoulburnScripts/scripts/tyflowFXLauncher.ms`

**First:** Read `tyflow_scripts/server/tyfx.py` signatures for `write_rain_script`, `write_dust_script`, `write_fire_script`. These are spine-free (no circuit spline required). Then add three new tabs to the existing `tabs tFXTabs` control:
- Tab 4: Rain — expose `rain_density`, `end_frame`, `site_z`
- Tab 5: Dust — expose `dust_density`, `end_frame`, `site_z`  
- Tab 6: Fire — expose `fire_intensity`, `end_frame`, `site_z`

Each new tab follows the same pattern as the Smoke tab: edittext for node names, spinners for params, three buttons (Generate / Open / Run).

### Task 6 — Rebuild EXE Installer with All New Files

After all icons and scripts are finalised, rebuild the EXE installer:
```powershell
cd SB2027
python installer/build_installer.py
# Output: SB2027/installer_dist/SoulburnScripts_v2_Setup.exe
```
Run the installer on the local Max 2027 install and verify:
1. All buttons show coloured icons (not white blanks)
2. Floating toolbar appears automatically on Max startup
3. MaxMaze works: create a Plane (8×8 segs), convert to Editable Poly, run Maze Generator
4. Custom Lighting Assistant: switch to Arnold, enable AOVs, verify render elements are added
5. tyFlow launcher: generate a smoke script, verify no TypeError from tyfx.py

---

## 6. Commands Quick Reference

```powershell
# Re-generate cuix after adding macros to SoulburnScripts.mcr
python SB2027/tools/make_cuix.py

# Re-generate smart icons
python SB2027/tools/make_smart_icons.py

# Check for any remaining execute(getINISetting) violations
Select-String -Path "SB2027\scripts\SoulburnScripts\scripts\*.ms" -Pattern 'execute\(getINISetting'

# Check for any remaining $scripts includes (should be empty)
Select-String -Path "SB2027\scripts\SoulburnScripts\scripts\*.ms" -Pattern '\$scripts\\'

# Check for any remaining hardcoded [400,400] positions
Select-String -Path "SB2027\scripts\SoulburnScripts\scripts\*.ms" -Pattern '\[400,400\]'

# List scripts whose icons are missing from UI_ln/Icons
Get-ChildItem "SB2027\scripts\SoulburnScripts\scripts\*.ms" | ForEach-Object {
    $n = $_.BaseName
    if (-not (Test-Path "UI_ln\Icons\SoulburnScripts_${n}_16a.bmp")) { "MISSING ICON: $n" }
}

# Deploy scripts to live ENU directory
Copy-Item "SB2027\scripts\SoulburnScripts\scripts\*.ms" `
    "C:\Users\mabdu\AppData\Local\Autodesk\3dsMax\2027 - 64bit\ENU\scripts\SoulburnScripts\scripts\"

# Deploy icons to live ENU directory
Copy-Item "UI_ln\Icons\SoulburnScripts_*" `
    "C:\Users\mabdu\AppData\Local\Autodesk\3dsMax\2027 - 64bit\ENU\UI_ln\Icons\"

# Run tyflow_scripts tests
cd tyflow_scripts; python -m pytest tests -q; cd ..

# Run max_mcp_server tests  
cd max_mcp_server; python -m pytest tests -q; cd ..

# Build EXE installer
cd SB2027; python installer/build_installer.py; cd ..

# Git: commit and push (ssnfts/soul-burn-2027)
cd SB2027  # or workspace root
git add -A
git commit -m "feat: [description]"
git push
```

---

## 7. Known Issues and Watch-Outs

1. **Icon white pixels** — see §4.1 and Task 1. Most likely either a Pillow BMP flip issue or the icons not being deployed to the live ENU path. Verify visually before assuming they are broken.

2. **`max_maze.py` original vs lib version** — the original at `C:\Users\mabdu\Downloads\scripts\max_maze.py` has `random.seed(SEED)` INSIDE `_backtracker()` (line 35) which makes the seed parameter to `run_maze()` irrelevant. The lib version at `SB2027/scripts/SoulburnScripts/lib/maze/max_maze.py` has this fixed. DO NOT copy from the original — use the lib version.

3. **`materialMoverCleanMeditVrayMtl`** — this macro has no icon file. It is a variant (not a UI tool) so it only needs `_16a`, `_16i`, `_24a`, `_24i` (not a separate `UI` version).

4. **Python 3.13 in Max 2027** — `sys.executable` inside Max returns `3dsmax.exe`. The embedded Python is 3.13, but the `__pycache__` files in `lib/maze/` and `lib/` show `cpython-311` — these are stale from an earlier session and can be deleted (`Remove-Item -Recurse "SB2027\scripts\SoulburnScripts\lib\**\__pycache__"`).

5. **`.cuix` deployment paths** — Max 2027 reads the toolbar configuration from `{ENU}\en-US\plugcfg\SoulburnScripts.cuix` (the primary path). The installer already deploys here. Do NOT rely on `{ENU}\UI_ln\SoulburnScripts.cuix` alone.

6. **`tyfx.py` is in a separate git repo** — `tyflow_scripts/` has its own `.git`. Changes to `tyfx.py` must be committed separately in that repo: `cd tyflow_scripts; git add -A; git commit -m "..."; git push; cd ..`.

7. **`sLib.ms` `global` declarations are ORDER-SENSITIVE** — they must appear BEFORE the outer `()` block body that defines the functions. They are at line 335 in the current file. Do not move them.

8. **`layerCleaner.ms` version boundary** — the `< 18.0` check may be `<= 17.0`. Not yet verified. Mark as blocked until someone tests on Max 2017.

9. **`texmapBaker.ms`** — RTT API changed in Max 2022. Do not mark as clean without a live test.

10. **Installer EXE must be run from inside `installer_dist/`** — the cx_Freeze bundle needs `lib/` beside it. Users must use `SB2027/RUN_INSTALLER.bat` or navigate to `installer_dist/` first.

---

## 8. Suggested Skills for This Session

Activate in order as needed:

| Skill | When |
|-------|------|
| `writing-plans` | Before starting any task — write a task-level plan with exact file paths |
| `implement` | When executing a plan for a specific task |
| `systematic-debugging` | If icons still appear white after the diagnosis steps in Task 1 |
| `diagnosing-bugs` | When MaxScript or Python scripts produce unexpected results in Max |
| `ponytail` | Before adding any new UI control — ask "does tyfx.py actually accept this param?" |
| `code-review` | After completing icon generation and the customLightingAssistant rollout additions |
| `verification-before-completion` | Before marking any task done — deploy to Max and verify visually |
| `matlab` | Only if signal-processing math arises in lighting assistant calculations (unlikely) |
| `architecture-diagram` | If you need to explain the toolbar + installer + script registry interaction |

---

## 9. External References (Do Not Re-Read Unless Needed)

- `COURSE-WEEK-3.md` — fully encoded into `customLightingAssistant.ms` already. Only re-read if adding the Lighting Theory Tips rollout (Task 4).
- `soulburn-2027-update-plan.md` — master spec. Read §Sub-Tasks for Sub-Tasks 2, 3, 4, 13 (not yet confirmed done).
- `TASK_LOG.md` — session-by-session history. Read only for context on a specific prior decision.
- `SB2027/CHANGELOG.md` — confirms what has been shipped in each version.
- `tyflow_scripts/server/tyfx.py` — read before touching tyflowFXLauncher.ms param list.

---

*End of handoff document. The next agent should start by running the icon diagnostic (Task 1, Step 1) — everything else is blocked on visible icons.*
