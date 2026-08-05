# SoulBurn Scripts Pack — 2027 Update Plan

---

## Code Quality Audit — Issues Found Across All Scripts

This section documents every concrete issue found by reading the actual source files. These feed into Sub-Tasks 1–8 and a new Sub-Task 13.

### Issue 1 — Universal Anti-Pattern: `execute(getINISetting(...))` in All 87 Scripts

Every script loads preferences with:

```maxscript
myVar = execute(getINISetting filename section key)
```

`execute()` runs arbitrary MaxScript from a string. A corrupted or hand-edited INI file silently evaluates whatever it finds — including `deleteFile` or `resetMaxFile`. It also silently returns `undefined` when a key is missing.

**Fix — typed INI reads, no execute:**
```maxscript
myIntVar   = (getINISetting f s k) as integer
myFloatVar = (getINISetting f s k) as float
myBoolVar  = (getINISetting f s k) == "true"
myArray    = filterString (getINISetting f s k) ","
```
**Scope:** All 87 scripts. Fix before any v2.0 release.

---

### Issue 2 — Dead Renderer Code Crashes Script Load in Max 2022+

Accessing a missing class literal (`Brazil_Advanced`, `VRayPhysicalCamera`, `Arch___Design__mi`) raises a hard error **before** any version-check can run. Scripts affected: `materialMover.ms`, `cameraFromPerspView.ms`, `bitmapCollector.ms`, `sLib.ms`, `modelPreparer.ms`, and more.

**Renderers that no longer exist:**

| Class | Renderer | Removed |
|-------|----------|---------|
| `Brazil_Advanced`, `BCam` | Brazil 1 | ~2010 |
| `Brazil2_Advanced_Material`, `Main_Camera` | Brazil 2 | ~2012 |
| `Arch___Design__mi`, `mental_ray` | Mental Ray | Max 2022 |
| `VRayPhysicalCamera` | V-Ray ≤4 | V-Ray 5 (2020) |

**Fix:** Delete Brazil 1/2 code entirely. Wrap all class references in `if (classof X != UndefinedClass)`. Replace Mental Ray with Physical Material. Update VRay camera detection to check both old and new class names.

`sLibWhatsCurrentRenderer()` in `sLib.ms` uses hardcoded class IDs — fragile across plugin versions. Replace with pattern matching:

```maxscript
fn sLibWhatsCurrentRenderer =
(
    local cls = (classof renderers.production) as string
    case of
    (
        (matchPattern cls pattern:"*V_Ray*"   ignoreCase:true): "vray"
        (matchPattern cls pattern:"*Arnold*"  ignoreCase:true): "arnold"
        (matchPattern cls pattern:"*Corona*"  ignoreCase:true): "corona"
        (matchPattern cls pattern:"*Scanline*"):                "scanline"
        default:                                                "unknown"
    )
)
```

---

### Issue 3 — `sLib.ms` Specific Bugs

| Line | Bug | Fix |
|------|-----|-----|
| 1187 | `return udnefined` (typo) | `return undefined` |
| All | `sLibFileExist` uses `getfiles` (glob, false-positive on special chars) | `doesFileExist filename` |
| All | `sLibMakeStringUppercase/Lowercase` manual 26-char replacement tables | `toUpper str` / `toLower str` (MaxScript 2014+) |
| All | Material editor iteration hardcoded to 24 slots (Compact editor only) | Add Slate editor path via `sme.GetMtlInParamEditor()` |
| Image path | `freeSceneBitmaps()` called repeatedly, flushes entire texture cache | Call at most once, or omit |
| Brazil light collectors | `(classof obj) == Brazil_Light` hard errors in Max 2022 | Wrap in `try/catch` or delete |

**Missing in sLib.ms — needed for v2.0:**
- `sLibGetArnoldLightMaps()` — maps on Arnold lights
- `sLibGetCoronaLightMaps()` — maps on CoronaLight / CoronaSun
- `sLibGetAllPhysicalMaterials()` — collect Physical Material instances from scene
- `sLibWhatsCurrentRenderer()` — updated (see Issue 2)

---

### Issue 4 — `splinePainter.ms` — `thePainterInterface` Removed in Max 2020

`thePainterInterface.InitializeCallback()` crashes with a hard runtime error in Max 2025+ — the global was removed from the SDK entirely. This makes `splinePainter.ms` completely non-functional without a rewrite.

**Fix:** Replace the painter system with `MouseTrack`:
```maxscript
fn myPaintCallback msg clickpos dir which shift ctrl alt =
(
    if msg == #mousePoint do ( -- place spline knot at clickpos )
    if msg == #mouseAbort do return #abort
    #continue
)
MouseTrack trackCallback:myPaintCallback cursor:#crossHair
```
`MouseTrack` is available since Max 2010 and is what all native tools use internally.

---

### Issue 5 — `geometryBanger.ms` — Biased Random Distribution

```maxscript
local vIndex = (random 0.00 1.99) as integer  -- Bug: 0→49.9%, 1→49.9%, never 2
```
Replace with `(random 1 2)` — the correct MaxScript integer random call.

---

### Issue 6 — `objectDropper.ms` — Magic Number `100` for Ray Offsets

Six near-identical ray cast blocks use `+100`/`-100` as ray start/end offsets, assuming scene units are centimetres with objects within 100 units. Wrong for VFX/arch scenes.

**Fix:** Derive offset from scene bounding box at call time:
```maxscript
local rayOffset = (distance sceneBBox.min sceneBBox.max) * 0.5
```

---

### Issue 7 — `edgeSelectByAngle.ms` — Epsilon Wrong Scale

`0.001` epsilon applied to degrees (result of `acos()` in MaxScript) is effectively zero tolerance (0.001° ≈ 0.000017 rad). Missed selections at exactly 90°. Fix: use `0.1` as the degree-scale epsilon.

---

### Issue 8 — `layerCleaner.ms` — Off-By-One in Version Check

`sLibMaxVer() < 18.0` should catch "before Max 2016" but Max 2016 itself returns exactly `18.0` and therefore takes the wrong code path. Fix: `<= 17.0`.

---

### Issue 9 — Global Variable Namespace Pollution in All Scripts

Every script declares its state as top-level MaxScript globals (`global nMFunction`, `global tRAMode`). Two scripts with a same-named variable silently corrupt each other's state.

**v2.0 fix — use struct containers:**
```maxscript
struct nameManagerState ( nMFunction = 1, nMItems = 1 )
global _nameManagerState = nameManagerState()
```

---

### Issue 10 — UI Window Position `[400,400]` Hard-Coded in All Scripts

Positions the window off-screen on 4K or multi-monitor setups.

**Fix — centre dynamically:**
```maxscript
fn sLibGetSafeUIPos w h =
(
    local sw = sysInfo.desktopSize.x
    local sh = sysInfo.desktopSize.y
    [sw/2 - w/2, sh/2 - h/2]
)
```
Add `sLibGetSafeUIPos` to `sLib.ms` and replace every `[400,400]` call.

---

### Issue 11 — `subdivisionManager.ms` — MeshSmooth Silently Fails on New Objects

`addModifier obj (Meshsmooth())` silently fails in Max 2025+ (class exists for backwards compat but doesn't add). Script never checks if the add succeeded.

**Fix:** Wrap in `try/catch`, fall back to TurboSmooth with a warning.

---

### Issue 12 — `materialMover.ms` Preset List Crashes on Load

Building the preset dropdown accesses `Brazil_Advanced`, `Brazil2_Advanced_Material`, `Arch___Design__mi` as class literals during UI construction — hard error in Max 2022+.

**Updated preset list for v2.0:**

| Preset | Class |
|--------|-------|
| Standard Material | `Standardmaterial` |
| Physical Material | `PhysicalMaterial` |
| VRay Material | `VRayMtl` |
| Arnold Standard Surface | `Arnold_Standard_Surface` |
| Corona Material | `CoronaMtl` |
| glTF Material | `GLTF_Material` |

---

### Issue 13 — `transformRandomizer.ms` Reproducibility Gap

No seed field. Every run produces different results. For procedural workflows, artists need to reproduce an exact randomization. Add a seed spinner and call `seed theValue` before the randomization loop.

---

### New Feature Additions to Existing Scripts (2027 Workflow Gaps)

| Script | Addition |
|--------|----------|
| `nameManager.ms` | USD-compliant name mode (strip spaces, slashes, non-ASCII); regex find/replace via .NET; batch rename from CSV |
| `objectReplacer.ms` | Preserve custom attributes on replace; replace by name regex pattern |
| `bitmapCollector.ms` | Arnold `.tx` tiled EXR support; UDIM tile collection (`name.1001.exr`…); CSV log output |
| `modifierUtilities.ms` | Mode 24: copy modifier stack to all selected; Mode 25: randomize modifier seed across selection |
| `instanceFinder.ms` | Convert instances to unique copies; instance statistics report (memory saving estimate) |
| `pivotPlacer.ms` | Align pivot to world axis (independent of position); "copy pivot from" picker |
| `transformRandomizer.ms` | Reproducible seed field; "randomize by Object ID" grouping mode |
| `objectDropper.ms` | Multi-axis drop (drop to closest surface in any direction); drop-and-embed mode |
| `bitmapCollector.ms` | Detect and report missing textures without copying (audit mode) |
| `layerCleaner.ms` | Option to merge empty layer content up before deleting |

---

## Top-Level Overview

SoulBurn Scripts Pack v1.12 is a discontinued 87-script 3ds Max productivity toolkit by Neil Blevins, last tested on Max 2017/2018 and targeting Max R2013–R2022. The pack covers modeling, UV, selection, materials, naming, rendering, splines, and workflow utilities — all written in MaxScript with a consistent architecture (sLib.ms shared library, INI-based preset persistence, paired Default/UI macros per script).

**Goal:** Produce a community-maintained **SoulBurn Scripts Pack v2.0 for 3ds Max 2025–2027**, bringing the existing scripts up to date, removing or replacing functionality that 3ds Max now ships natively, fixing known compatibility breaks, adding missing modern features (Arnold/Redshift/Corona renderer support, Smart Extrude, physical camera, OSL maps, etc.), and packaging the result with a modern dark-UI installer compatible with Max 2025 and 2027.

**Scope:**
1. Audit every script against Max 2025/2027 native capabilities → mark as **Obsolete**, **Needs Update**, or **Still Valuable**
2. Fix all compatibility issues in scripts that are still valuable
3. Add new scripts that address 2027 workflows not covered by vanilla Max
4. Modernize the shared library (sLib.ms) and packaging

**Non-goals:**
- Porting to Python (MaxScript is still fully supported in Max 2027)
- Rewriting logic that already works correctly
- Adding game-engine or real-time features
- Redshift support (deferred to a future v2.x release)

---

## Feature Audit: SoulBurn vs 3ds Max 2025–2027 Native

### Already Covered Natively in Max 2025+

These scripts can be marked **Obsolete** because Max now ships equivalent or superior built-in tools:

| Script | Native Replacement |
|--------|-------------------|
| `calculatorLauncher.ms` | Windows Calculator / Max Expression Editor |
| `layerCleaner.ms` | Scene Explorer → Layer right-click "Delete Empty Layers" |
| `xFormResetter.ms` | Reset XForm utility (built-in since Max 2021) |
| `subdivisionIterationManip.ms` | OpenSubdiv controls in Modify panel |
| `vertexAndEdgeConnector.ms` | Smart Extrude + Connect (native, improved in Max 2024+) |
| `viewportControl.ms` | Viewport Controls ribbon / View cube (Max 7+ native) |
| `pFlowRemover.ms` | Particle View delete is now direct (PFlow improved) |
| `snapShoter.ms` | Snapshot utility (built-in, now creates EditablePoly directly) |
| `maxfileOldVersionSaver.ms` | Max native File → Save As with version picker |
| `twoDPlanView.ms` | Orthographic viewport presets in Max 2023+ |

### Still Valuable but Need Compatibility Updates

These scripts work conceptually but reference deprecated APIs, old renderer classes, or pre-Max-2020 patterns:

| Script | Issue | Fix Needed |
|--------|-------|-----------|
| `vraySamplingSubdivManager.ms` | VRay API changed post v5 (V-Ray 6/7 uses adaptive sampling, removed Subdivision) | Rewrite for VRay 6 Progressive / Arnold / Corona |
| `vrayMatteManager.ms` | VRay matte material class path changed in VRay 6 | Update class names |
| `soulburnAssetLoader.ms` | Paths, icon formats, max version checks out of date | Update paths + add `.exr`/`.hdr` env support |
| `texmapBaker.ms` | RTT (Render to Texture) API changed in Max 2022 | Update RTT calls |
| `cameraFromPerspView.ms` | Physical Camera is now default; creates legacy Target Camera | Add Physical Camera output option |
| `cameraLensPackager.ms` | Lens parameters changed with Physical Camera | Extend for Physical Camera |
| `modelPreparer.ms` | Hardcoded VRay material paths; Brazil renderer references | Update renderer detection, add Arnold/Corona |
| `curvatureMaker.ms` | VRay-dependent; output workflow changed | Update for modern bake workflows |
| `parameterManager.ms` | Tested only on Max 2011; many parameter names changed | Full audit of parameter access patterns |
| `viewportToVFBLoader.ms` | VFB2 (V-Ray 5+) has different API | Update for VFB2 |
| `modifierUtilities.ms` | Modifier class names changed for some modifiers | Audit modifier class list |
| `subdivisionManager.ms` | OpenSubdiv vs legacy TurboSmooth/MeshSmooth split | Add OpenSubdiv support |

### Still Fully Valuable (Minor or No Changes Needed)

These scripts provide genuine productivity value not replicated natively:

| Script | Value |
|--------|-------|
| `nameManager.ms` | 14 rename modes; far more powerful than native |
| `objectReplacer.ms` | Batch replace with instance/copy/ref; native version limited |
| `objectPainter.ms` | Paint objects onto surface; no native equivalent |
| `transformRandomizer.ms` | Per-axis random transform; native scatter less controllable |
| `wireColorRandomizer.ms` | Simple but no native equivalent |
| `pivotPlacer.ms` | 27-position pivot placement; native is more limited |
| `instanceFinder.ms` | Find/isolate instances; no native panel |
| `bitmapCollector.ms` | Asset consolidation to single folder |
| `geometryBanger.ms` | Random vertex displacement (selective); no native equivalent |
| `uVFlattener.ms` | UV align to min/max/average; Unwrap editor lacks this |
| `uVPlacer.ms` | UV placement control |
| `uVTransfer.ms` | UV channel transfer between objects |
| `uVFlattenMapper.ms` | Flatten UV mapper with controls |
| `uVAreaDisplayer.ms` | UV area analysis |
| `materialFromSelectedObject.ms` | Quick material extraction |
| `materialMover.ms` | Move materials between objects |
| `materialInfoDisplayer.ms` | Material slot info |
| `objectSelectorByMaterial.ms` | Select all by material |
| `edgeSelectByAngle.ms` | Angle-based edge selection |
| `elementSelectByFace.ms` | Face-to-element selection |
| `thinFaceSelector.ms` | Thin face detection |
| `polyCountSelector.ms` | Select by poly count |
| `transformSelector.ms` | Select by transform values |
| `selectionRandomizer.ms` | Random object selection |
| `instanceTrimmer.ms` | Reduce instance count |
| `uniqueObjectFinder.ms` | Find non-instanced objects |
| `objectUniquefier.ms` | Make unique from instances |
| `objectDropper.ms` | Drop objects to surface |
| `layerCleaner.ms` | Still faster than UI flow |
| `splineKnotManager.ms` | Spline knot editing tools |
| `splinePainter.ms` | Paint splines on surface |
| `splineManager.ms` | Spline batch operations |
| `customAttributeRemover.ms` | Clean custom attributes |
| `parentSelector.ms` | Navigate hierarchy |
| `nodeTypeDisplayer.ms` | Show node types in scene |
| `iDSetter.ms` | Batch set IDs |
| `circleArrayMaker.ms` | Circular arrays |
| `edgeDivider.ms` | Edge subdivision |
| `mirrorObjectAlongAxis.ms` | Mirror utility |
| `renderSizer.ms` | Quick render output size |
| `softSelectionControl.ms` | Soft selection helpers |
| `vertexMapDisplayer.ms` | Vertex map preview |
| `vertPlacer.ms` | Vertex placement |
| `vertSelectionToObject.ms` | Convert vert sel to obj |
| `imagePlaneMaker.ms` | Image plane helper |
| `groupWithPoint.ms` | Group + add point helper |
| `pipeMaker.ms` | Pipe/tube generation |
| `wireMaker.ms` | Wire creation from splines |
| `blendedBoxMapMaker.ms` | BlendedBoxMap creation |
| `blendedBoxMapManager.ms` | BlendedBoxMap management |
| `blendedCubeProjectionMaker.ms` | Cube projection |
| `blendedCubeProjectionManager.ms` | Cube projection mgmt |
| `materialRemover.ms` | Remove material from objects |
| `alignViewportToFace.ms` | Align viewport to selected face |
| `objectAttacher.ms` | Batch attach objects |
| `objectDetacher.ms` | Batch detach elements |

---

## New Scripts to Add for 2027

Scripts that address modern workflows not in the original pack:

| Script Name | Purpose |
|-------------|---------|
| `arnoldMaterialManager.ms` | Arnold Surface/Standard material batch manager (like vraySamplingSubdivManager) |
| `coronaMaterialManager.ms` | Corona material manager (scatter, displacement toggles) |
| `physicalCameraManager.ms` | Batch control Physical Camera exposure, f-stop, ISO, WB across scene |
| `smartExtrudeHelper.ms` | Smart Extrude batch operations on multi-object selections |
| `oslMapBrowser.ms` | Browse, preview, and assign OSL maps from a picker UI |
| `dataChannelCleaner.ms` | Clean / rename / remove Data Channel modifier data stores |
| `geometryNodesBridge.ms` | Export selected geometry as Alembic for Blender Geometry Nodes round-trip |
| `gltfExportHelper.ms` | Guided glTF/glb export with material validation checklist |
| `nestingOptimizer.ms` | Analyze and suggest nesting/instancing opportunities to reduce poly count |
| `soulburnScriptsUpdater.ms` | Check GitHub for updates and download new script versions |

---

## Sub-Tasks

---

### Sub-Task 1: Compatibility Layer — Update sLib.ms for Max 2025/2027

**Status:** `[ ] pending`

**Intent:**  
The shared library `sLib.ms` is the foundation of every script. It has renderer detection that only knows Brazil, V-Ray, and Mental Ray. It must be updated to detect Arnold, Redshift, Corona, and V-Ray 6+, and any deprecated MaxScript APIs must be replaced.

**Expected Outcomes:**
- `sLib.ms` detects Arnold (`ARNOLD_2023+`), Redshift, Corona, V-Ray 6+
- Deprecated `getClassInstances` calls replaced where needed
- `sLibGetRenderer()` returns correct enum for Max 2025/2027 renderer
- All existing scripts that call sLib continue to work without changes

**Todo List:**
1. Read full `sLib.ms` content
2. Identify all renderer detection functions and update for modern renderers
3. Identify any MaxScript functions removed post-Max 2022 (getClassInstances, etc.)
4. Add `sLibGetRendererName()` helper that returns string name for UI display
5. Bump library version to v2.00
6. Add revision history entry

**Relevant Context:**
- File: `scripts/SoulburnScripts/lib/sLib.ms`
- Max 2025 uses Arnold as default renderer (`Default_Scanline_Renderer` still present but hidden)
- V-Ray 6 changed class names from `VRayMtl` patterns

---

### Sub-Task 2: Remove / Archive Obsolete Scripts

**Status:** `[ ] pending`

**Intent:**  
Scripts superseded by native Max tools should be removed from the main distribution to reduce clutter, or placed in an `archived/` subfolder with a deprecation notice.

**Expected Outcomes:**
- 10 obsolete scripts moved to `scripts/SoulburnScripts/scripts/archived/`
- A `DEPRECATED.md` file lists each with native replacement
- Macros for archived scripts removed from `SoulburnScripts.mcr`
- Icon files for archived scripts moved to `UI_ln/Icons/archived/`

**Todo List:**
1. Create `scripts/SoulburnScripts/scripts/archived/` directory
2. Move the 10 obsolete scripts listed in the audit table above
3. Create `DEPRECATED.md` with the replacement table
4. Remove corresponding macro entries from `MacroScripts/SoulburnScripts.mcr`
5. Move corresponding icons

**Relevant Context:**
- Obsolete scripts: `calculatorLauncher.ms`, `layerCleaner.ms`, `xFormResetter.ms`, `subdivisionIterationManip.ms`, `vertexAndEdgeConnector.ms`, `viewportControl.ms`, `pFlowRemover.ms`, `snapShoter.ms`, `maxfileOldVersionSaver.ms`, `twoDPlanView.ms`
- `MacroScripts/SoulburnScripts.mcr` registers macros using `Include` pattern

---

### Sub-Task 3: Fix VRay Scripts for V-Ray 6/7

**Status:** `[ ] pending`

**Intent:**  
V-Ray 5+ ships VFB2 and V-Ray 6 removed Subdivision-based sampling in favour of progressive adaptive rendering. Scripts that manipulate VRay-specific properties must be rewritten to use current V-Ray class names and APIs.

**Expected Outcomes:**
- `vraySamplingSubdivManager.ms` updated to control V-Ray 6 progressive sample settings OR repurposed as `vrayMaterialBatchManager.ms`
- `vrayMatteManager.ms` updated for V-Ray 6 matte/shadow class names
- `viewportToVFBLoader.ms` updated for VFB2 API
- `modelPreparer.ms` updated — Brazil references removed, Arnold/Redshift/Corona modes added

**Todo List:**
1. Read full content of `vraySamplingSubdivManager.ms`, `vrayMatteManager.ms`, `viewportToVFBLoader.ms`, `modelPreparer.ms`
2. Map old V-Ray class names to V-Ray 6 equivalents
3. Replace subdivision sampling controls with V-Ray 6 progressive sampling parameters
4. Update VFB2 API calls in `viewportToVFBLoader.ms`
5. Add Arnold / Redshift / Corona matte support in `vrayMatteManager.ms` → rename to `matteManager.ms`
6. Test each script stub structure

**Relevant Context:**
- V-Ray 6: `VRayMtl` still exists but `VRaySamplerInfo` is deprecated
- VFB2 uses `vray.vfb` interface instead of `vray.vfbControl`

---

### Sub-Task 4: Fix Camera Scripts for Physical Camera

**Status:** `[ ] pending`

**Intent:**  
3ds Max 2016+ ships Physical Camera as the recommended camera type. `cameraFromPerspView.ms` and `cameraLensPackager.ms` only create/manage legacy Target/Free cameras. They need a Physical Camera mode.

**Expected Outcomes:**
- `cameraFromPerspView.ms`: adds radio button Physical Camera vs Legacy Camera; when Physical selected, creates `Physical_Camera` class with correct FOV/sensor match
- `cameraLensPackager.ms`: extends lens presets to set Physical Camera focal length and sensor size
- Both scripts tested with Max 2025 Physical Camera class

**Todo List:**
1. Read full `cameraFromPerspView.ms` and `cameraLensPackager.ms`
2. Add Physical Camera creation path using `Physical_Camera` MaxScript class
3. Preserve legacy path for users on older renderers that don't support Physical Camera
4. Update UI rollouts to expose camera type selector
5. Update version numbers and revision history

**Relevant Context:**
- Max 2025 Physical Camera class: `PhysCamera` / `Physical_Camera`
- Legacy: `Targetcamera`, `Freecamera`

---

### Sub-Task 5: Add Multi-Renderer Material Managers

**Status:** `[ ] pending`

**Intent:**  
The original pack only had VRay material helpers. Arnold, Redshift, and Corona are all widely used in 2027. This sub-task creates three new scripts following the exact SoulBurn architecture pattern.

**Expected Outcomes:**
- `arnoldMaterialManager.ms`: batch toggle Arnold material properties (subdivision, displacement, opacity, visibility flags) across selection
- `coronaMaterialManager.ms`: batch control Corona material displacement, scatter density, and render override flags
- `physicalCameraManager.ms`: batch control exposure value, ISO, f-stop, shutter across all Physical Cameras in scene
- Each script follows identical header/globals/include/variables/main/UI/save/load structure as `nameManager.ms`
- Each registered in `SoulburnScripts.mcr` with Default and UI macros
- Icons created (placeholder .bmp at minimum)

**Todo List:**
1. Use `objectReplacer.ms` as structural template
2. Write `arnoldMaterialManager.ms` — target class `Standard_Surface` (Arnold)
3. Write `coronaMaterialManager.ms` — target class `CoronaMtl`
4. Write `physicalCameraManager.ms` — target class `Physical_Camera`
5. Register all three in `SoulburnScripts.mcr`
6. Create placeholder icons in `UI_ln/Icons/` and `UI_ln/IconsDark/`

**Relevant Context:**
- Arnold material class in MaxScript: `Arnold_Standard_Surface`
- Corona material: `CoronaMtl`
- Existing pattern: `vraySamplingSubdivManager.ms`

---

### Sub-Task 6: Add OSL Map Browser

**Status:** `[ ] pending`

**Intent:**  
OSL (Open Shading Language) maps were added in Max 2019 and are heavily used in 2025+. There is no built-in browser to preview and assign OSL map presets. This script fills that gap.

**Expected Outcomes:**
- `oslMapBrowser.ms`: scans the OSL map directories, shows thumbnails (or names), lets user pick a map and assigns it to selected material slot
- Supports Max's default OSL map location and custom search paths
- Follows SoulBurn script architecture

**Todo List:**
1. Identify OSL map default paths in Max 2025 (`maps/OSL/`)
2. Write file-scanning function in `sLib.ms` or inline
3. Write list/picker UI rollout
4. Wire "Apply" to assign selected OSL map to picked material channel
5. Register in `SoulburnScripts.mcr`

**Relevant Context:**
- OSL maps stored as `.osl` / `.oso` files under 3ds Max install `maps/OSL/`
- Max 2025 OSLMap class: `OSLMap`

---

### Sub-Task 7: Add glTF Export Helper

**Status:** `[ ] pending`

**Intent:**  
glTF/glb export for game engines, web 3D, and Blender round-trips is a standard 2025 workflow. Max 2023+ ships a glTF exporter but it has many gotchas (material translation, units, UV channels). This script provides a guided pre-export checklist and one-click export.

**Expected Outcomes:**
- `gltfExportHelper.ms`: runs pre-export validation (checks for missing UVs, material types incompatible with glTF PBR, non-uniform scale, out-of-range values), shows a report, then calls the native glTF exporter with correct settings
- Supports export of selection or entire scene
- Follows SoulBurn architecture

**Todo List:**
1. Research Max 2025 glTF export MAXScript interface (`exportFile` with glTF format string)
2. Write validation checks: UV channel 1, material type (Physical or PBR required), scale
3. Write report rollout listing issues found
4. Wire "Export" button to `exportFile` call with glTF settings
5. Register in `SoulburnScripts.mcr`

**Relevant Context:**
- Max 2025 glTF export: `exportFile filename #noPrompt using:GLTF_Export`
- PBR material in Max: `Physical_Material` or `glTF_Material`

---

### Sub-Task 9: Integrate `cinematic_cameras` as MaxScript Camera Moves Tool

**Status:** `[ ] pending`

**Intent:**
The `cinematic_cameras/` folder contains a pure Python module (`cinecam.py`) verified against a live 3ds Max 2027 + V-Ray 7 host. It implements 10 professional camera move algorithms — arc, dolly, truck, pedestal, tracking, pass-through, helix, whip pan, handheld, dolly zoom — each producing keyframe arrays. These need to be surfaced in Max as a SoulBurn-style interactive UI script so artists can pick a move type, dial parameters, and have keys written to a selected Physical Camera.

**Expected Outcomes:**
- New MaxScript file: `scripts/SoulburnScripts/scripts/cinematicCameraMaker.ms`
- UI rollout: dropdown for move type (Arc / Dolly / Truck / Pedestal / Tracking / Pass-Through / Helix / Whip Pan / Handheld / Dolly Zoom), frame range, per-move parameter fields (radius, height, bearing, sweep, etc.), subject object picker, FOV field
- On execute: calls `python.ExecuteString` to run the corresponding `cinecam.py` function, captures the keyframe array, then writes pos/target/fov keys to the active Physical Camera using `pymxs.attime` + `setKey` — or pure MaxScript equivalent loop
- `clamp_above` option (terrain collision guard) exposed as a checkbox
- `check_moves` validation result shown in a status label before committing keys
- Registered in `SoulburnScripts.mcr` as `cinematicCameraMaker` (default) + `cinematicCameraMakerUI` (UI)
- Icons created in `UI_ln/Icons/` and `UI_ln/IconsDark/`

**How the Python-to-MaxScript Bridge Works:**
- `cinecam.py` is pure Python (no DCC imports) — can be called from 3ds Max's embedded Python (`python.ExecuteString` / `python.ExecuteFile`)
- Each move function returns a list of `{"frame": int, "pos": [x,y,z], "target": [x,y,z], "fov": float}` dicts
- MaxScript reads the returned list, loops over keys, and applies them to a Target Camera or Physical Camera via `with animate on` + `at time f` blocks
- Alternatively uses the Atlas bridge (`max_mcp_server`) if bridge is running — auto-detected at script startup

**Todo List:**
1. Copy `cinematic_cameras/server/cinecam.py` into `scripts/SoulburnScripts/lib/cinecam.py` (install-time step)
2. Write `cinematicCameraMaker.ms` following standard SoulBurn header/globals/include/variables/main/UI/save/load structure
3. Add a `sLibRunPythonCineMove()` helper in `sLib.ms` that calls `python.ExecuteFile` to load cinecam and returns keyframe data via a temp JSON file
4. Write the MaxScript key-writing loop using `with animate on` + `at time` blocks for pos/target/fov on a Target Camera node
5. Add `clamp_above` and `check_moves` integration (report-only, does not block)
6. Write save/load INI for all move parameters
7. Register macros in `SoulburnScripts.mcr`
8. Create icons

**Relevant Context:**
- Python in 3ds Max: `python.ExecuteFile @"<path>"`, `python.ExecuteString "<code>"`
- `cinecam.py` location in this workspace: `cinematic_cameras/server/cinecam.py`
- All 10 move functions in `cinecam.py` are pure and offline-testable
- Target camera key writing in MaxScript: `with animate on ( at time f (cam.pos = ...) )`
- Physical Camera FOV: `cam.fov = degrees` via `setProperty`
- `cinematic_cameras/` is a standalone git repo; copy only `cinecam.py` into SoulBurn's lib

---

### Sub-Task 10: Integrate `tyflow_scripts` as tyFlow FX Launcher

**Status:** `[ ] pending`

**Intent:**
The `tyflow_scripts/` folder contains `tyfx.py` and `raceanim.py` — a Python module that generates reviewable MaxScript for three tyFlow effect graphs (tyre smoke, crash debris, sparks). The workflow is: generate MaxScript → save to disk → operator reviews → run. This needs a MaxScript wrapper that lets artists drive the whole flow from a single SoulBurn UI panel without touching the Python directly.

**Expected Outcomes:**
- New MaxScript file: `scripts/SoulburnScripts/scripts/tyflowFXLauncher.ms`
- UI rollout with three tabs: Tyre Smoke, Crash Debris, Crash Sparks
- Per-tab: node picker (emitter meshes or wing meshes), parameter fields, Generate button (writes .ms to disk), Open button (opens generated .ms in MaxScript editor for review), Run button (executes via `python.ExecuteString` if `ATLAS_ALLOW_MAXSCRIPT=1`)
- Status display showing summary returned by `tyfx.write_*_script()`
- Explicit warning label: "Review generated script before running — executes arbitrary code in Max"
- Registered in `SoulburnScripts.mcr` as `tyflowFXLauncher` + `tyflowFXLauncherUI`
- Icons created

**How the Python-to-MaxScript Bridge Works:**
- `tyfx.py` writes a `.ms` file to disk and returns a `{"path", "lines", "summary", "params"}` dict
- MaxScript calls `python.ExecuteString` to run `tyfx.write_smoke_script(...)` and reads the returned path
- The generated `.ms` file is then loaded into the MaxScript editor via `openMaxscriptEditor path` or run via `fileIn path`
- `raceanim.py` is required by `tyfx.py` — both must be copied to `scripts/SoulburnScripts/lib/`
- Spine data (circuit vertex array) is stored in the UI as a file path to a JSON file the user provides

**Todo List:**
1. Copy `tyflow_scripts/server/tyfx.py` and `tyflow_scripts/server/raceanim.py` into `scripts/SoulburnScripts/lib/`
2. Write `tyflowFXLauncher.ms` — three-tab SoulBurn rollout
3. Add Tyre Smoke tab: emitter node list, wind bearing, wind speed, speed threshold, end frame, site Z
4. Add Crash Debris tab: wing node list, end frame, site Z, FPS
5. Add Crash Sparks tab: floor node list, end frame, site Z, FPS
6. Wire Generate buttons to `python.ExecuteString` calls that invoke `tyfx.write_*_script()`
7. Wire Open buttons to open the generated `.ms` in the MaxScript editor
8. Wire Run buttons with a prominent warning dialog, then `fileIn` the generated `.ms`
9. Register macros in `SoulburnScripts.mcr`
10. Create icons
11. Add a "tyFlow not installed" detection using `classOf tyFlow == UndefinedClass` at script load

**Relevant Context:**
- `tyfx.py` location: `tyflow_scripts/server/tyfx.py`
- `raceanim.py` location: `tyflow_scripts/server/raceanim.py`
- `ATLAS_ALLOW_MAXSCRIPT` env var gates execution — the UI must show this requirement clearly
- MaxScript open file in editor: `openMaxscriptEditorFile path` or `execute (openFile path)`
- tyFlow availability check in MaxScript: `(classOf tyFlow) != UndefinedClass`
- `tyflow_scripts/` is a standalone git repo; copy only `tyfx.py` and `raceanim.py`

---

### Sub-Task 11: Integrate `max_mcp_server` as Atlas Bridge Launcher

**Status:** `[ ] pending`

**Intent:**
The `max_mcp_server/` folder is a fully functioning MCP server for 3ds Max 2027 + V-Ray 7. It contains a Python bridge (`atlas_max_bridge.py`, `atlas_max_handlers.py`) that runs inside Max and exposes scene control, mesh creation, keying, rendering, OSM building import, terrain, solar positioning, and tyFlow effects as MCP tools. It needs to be surfaced inside Max via a SoulBurn-style launcher script so artists can start/stop the bridge with one click, and an additional "scene builder" SoulBurn script that drives the key `atlas_build_scene` workflow.

**Expected Outcomes:**

**File 1 — `atlasBridgeLauncher.ms`:**
- Start/Stop toggle button for the Atlas bridge (calls `python.ExecuteFile start_bridge.py`)
- Bridge status indicator (ping check via socket)
- Port display (default 9879, matches `ATLAS_MAX_PORT`)
- "Open Bridge Log" button showing last bridge output
- Registered as `atlasBridgeLauncher` + `atlasBridgeLauncherUI` in `SoulburnScripts.mcr`

**File 2 — `atlasCineSceneBuilder.ms`:**
- UI to drive `atlas_build_scene` without writing Python: lat/lon fields, local time picker, building radius, terrain toggle, reset scene checkbox
- "Fetch Preview" button (calls `atlas_fetch_context` via bridge socket)
- "Build Scene" button (calls `atlas_build_scene` via bridge socket)
- "Set Sun" button (calls `atlas_set_sun`)
- "Place Camera" button (wraps `atlas_place_camera`)
- "Render" button (calls `atlas_render`)
- Registered as `atlasCineSceneBuilder` + `atlasCineSceneBuilderUI`
- Communicates with bridge via a thin MaxScript socket caller function in `sLib.ms`

**File 3 — `atlasCameraKeyWriter.ms`:**
- Bridges `cinecam.py` camera moves and the `cmd_set_keys` bridge command
- Move type dropdown + parameter fields identical to Sub-Task 9
- "Write Keys via Bridge" button sends keyframe data through the bridge socket instead of writing MaxScript directly
- Useful when the bridge is already running (avoids `python.ExecuteFile` overhead)

**How the MaxScript-to-Bridge Socket Call Works:**
- Bridge listens on `127.0.0.1:9879` (TCP, newline-delimited JSON)
- MaxScript sends a command using `dotNetObject "System.Net.Sockets.TcpClient"` + `StreamWriter`
- Request format: `{"cmd": "set_keys", "node": "Atlas_Cam", "keys": [...]}` + `\n`
- Response: `{"ok": true, "result": {...}}` or `{"ok": false, "error": "..."}`
- A reusable `sLibAtlasBridgeCall(cmdName, paramsObj)` helper encapsulates this in `sLib.ms`

**Todo List:**
1. Copy `max_mcp_server/bridge/atlas_max_bridge.py`, `atlas_max_handlers.py`, `start_bridge.py` into `scripts/SoulburnScripts/lib/atlas/`
2. Write `atlasBridgeLauncher.ms` — start/stop toggle, status ping, port display
3. Add `sLibAtlasBridgeCall()` to `sLib.ms` using .NET TCP socket (no external dependencies)
4. Write `atlasCineSceneBuilder.ms` — lat/lon/time/radius UI wiring to bridge commands
5. Write `atlasCameraKeyWriter.ms` — camera move UI that writes keys via the bridge
6. Register all three scripts in `SoulburnScripts.mcr` with Default + UI macros
7. Create icons for all three
8. Add bridge availability detection: if socket connect fails, show "Start Atlas Bridge first" message

**Relevant Context:**
- Bridge files: `max_mcp_server/bridge/` (3 Python files)
- Bridge port: `9879` (configurable via `ATLAS_MAX_PORT` env var)
- `cmd_set_keys`, `cmd_ping`, `cmd_render`, `cmd_scene_list`, `cmd_node_get`, `cmd_node_set` are all already implemented in `atlas_max_handlers.py`
- MaxScript .NET TCP: `dotNetObject "System.Net.Sockets.TcpClient"` (available since Max 2014)
- `max_mcp_server/` is a standalone git repo; copy only the `bridge/` subfolder

---

### Sub-Task 8: Package and Version Bump

**Status:** `[ ] pending`

**Intent:**
Produce a clean v2.0 release: updated README, a `CHANGELOG.md`, bumped version references across all files, a dark-mode UI pass, and a `soulburnScriptsLister.ms` update to show the new scripts.

**Expected Outcomes:**
- `README.md` at root: installation instructions, feature list, credits
- `CHANGELOG.md`: lists all changes from v1.12 to v2.0
- Version string in `SoulburnScripts.mcr` bumped to v2.00
- `soulburnScriptsLister.ms` updated to include all new scripts
- Dark mode icons added for all new scripts
- All file headers updated with "Tested: Max 2027"

**Todo List:**
1. Write `README.md`
2. Write `CHANGELOG.md`
3. Update version in `SoulburnScripts.mcr` header and `soulburnScriptsLister.ms`
4. Add placeholder dark icons for new scripts
5. Final pass: update "Tested: Max 2027" in all modified files

**Relevant Context:**
- `soulburnScriptsLister.ms` lists all available scripts in a picker UI

---

### Sub-Task 12: Windows Installer EXE

**Status:** `[ ] pending`

**Intent:**
Replace the old manual "copy files" instructions with a proper Windows installer executable (`SoulburnScripts_v2_Setup.exe`). The installer auto-detects every installed version of 3ds Max on the machine by scanning the Windows Registry, presents a checklist of found versions, copies files to the correct per-version user paths, optionally installs the Python bridge dependencies, and offers a clean Uninstall entry in Windows Add/Remove Programs.

**Expected Outcomes:**
- `installer/SoulburnScripts_v2_Setup.exe` — a single double-clickable installer
- On launch: detects all installed 3ds Max versions (2020–2027) via registry and `%LOCALAPPDATA%`
- Shows a GUI checklist: user picks which Max version(s) to install into
- Copies all four file trees to the correct per-version paths
- Optional step: runs `pip install PySide6 fastmcp pandas shapely` into Max's embedded Python
- Optional step: creates a desktop shortcut for the Atlas Bridge Launcher documentation
- Writes an uninstall entry to `HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\SoulburnScripts`
- Uninstaller removes only the files the installer placed — does not touch user scenes or presets
- Progress bar with per-file status
- Final screen: "Installation complete — open Customize > Toolbars in 3ds Max to add buttons"

**Installer Technology: Python + cx_Freeze → .exe**

The installer is written in Python using `tkinter` for the GUI (ships with Python, zero extra dependencies for the installer itself) and compiled to a standalone `.exe` using `cx_Freeze`. This means:
- No NSIS, Inno Setup, or WiX required — pure Python, readable source
- The source lives at `installer/installer.py` + `installer/build_installer.py`
- CI can rebuild the `.exe` with `python build_installer.py build_exe`
- The `.exe` is self-contained — users do not need Python installed

**Max Version Detection Logic:**

3ds Max user data lives at:
```
%LOCALAPPDATA%\Autodesk\3dsMax\{VERSION} - 64bit\ENU\
```
Where `{VERSION}` is `2020`, `2021`, `2022`, `2023`, `2024`, `2025`, `2026`, `2027`.

Detection uses two methods in order:
1. **Registry scan** — `HKLM\SOFTWARE\Autodesk\3dsMax\{major_version}` where major versions map to product years (e.g. `24.0` = 2022, `25.0` = 2023, `26.0` = 2024, `27.0` = 2025, `28.0` = 2026, `29.0` = 2027)
2. **Filesystem fallback** — check if `%LOCALAPPDATA%\Autodesk\3dsMax\{VERSION} - 64bit\ENU\` exists

A detected version is shown with a checkbox. Versions not found are shown greyed out.

**Per-Version Install Mapping:**

```
Source                                  → Destination (per selected Max version)
──────────────────────────────────────────────────────────────────────────────
scripts/SoulburnScripts/                → {ENU}\scripts\SoulburnScripts\
MacroScripts/SoulburnScripts.mcr        → {ENU}\scripts\Startup\SoulburnScripts.mcr
MacroScripts/SoulburnScriptsExtras.mcr  → {ENU}\scripts\Startup\SoulburnScriptsExtras.mcr
UI_ln/Icons/                            → {ENU}\UI_ln\Icons\
UI_ln/IconsDark/                        → {ENU}\UI_ln\IconsDark\
```
Where `{ENU}` = `%LOCALAPPDATA%\Autodesk\3dsMax\{VERSION} - 64bit\ENU`

**Python Bridge Dependencies (optional tab in installer):**

For the Atlas Bridge scripts, a separate "Install Python Dependencies" checkbox runs:
```
"{MAX_INSTALL_ROOT}\Python\python.exe" -m pip install PySide6 fastmcp pandas shapely
```
The Max install root is read from the registry key `InstallDir`. This uses Max's own embedded Python (not the user's system Python), which is the same interpreter the bridge runs in.

**Todo List:**
1. Write `installer/installer.py`:
   - `detect_max_versions()` — registry scan + filesystem fallback, returns `[{version, year, enu_path, install_dir, python_exe}]`
   - `InstallWizard(tk.Tk)` — 3-page wizard: Welcome → Version select + options → Progress → Done
   - `install_to_version(version_info, options)` — copies file trees, handles existing files (prompt overwrite or backup)
   - `uninstall_entry(version_info)` — writes uninstall registry key + `uninstall_manifest.json` listing every file placed
   - `run_pip(python_exe, packages)` — runs pip in subprocess with live output to progress text widget
2. Write `installer/build_installer.py` — cx_Freeze setup script that bundles `installer.py` + all SoulBurn source files into a single `SoulburnScripts_v2_Setup.exe`
3. Write `installer/installer_icon.ico` — simple icon (placeholder acceptable)
4. Test detection on a machine with multiple Max versions
5. Test uninstall: verify no SoulBurn files remain, verify user INI presets in `plugcfg/` are preserved

**GUI Layout (3-page wizard):**

```
Page 1 — Welcome
  [SoulBurn logo / title]
  "SoulBurn Scripts Pack v2.0 for 3ds Max"
  "Installs 89 productivity scripts for 3ds Max 2020–2027."
  [Next >]

Page 2 — Select Installation Targets
  "Detected 3ds Max versions:"
  ☑ 3ds Max 2027  (C:\Users\…\3dsMax\2027 - 64bit\ENU)
  ☑ 3ds Max 2025  (C:\Users\…\3dsMax\2025 - 64bit\ENU)
  ☐ 3ds Max 2023  (not found)
  ─────────────────────────────────────────────
  Options:
  ☑ Install Atlas Bridge Python dependencies (PySide6, fastmcp, pandas, shapely)
  ☑ Backup existing SoulburnScripts folder before overwriting
  [< Back]  [Install]

Page 3 — Progress
  Installing into 3ds Max 2027...
  ✓ scripts\SoulburnScripts\lib\sLib.ms
  ✓ scripts\SoulburnScripts\scripts\nameManager.ms
  … (89 lines)
  ✓ MacroScripts\SoulburnScripts.mcr
  ✓ UI_ln\Icons\ (412 files)
  Installing Python dependencies...
  ✓ PySide6 installed
  ✓ fastmcp installed
  [Done]

Page 4 — Finish
  ✓ Installed into 2 version(s) of 3ds Max
  "Open 3ds Max → Customize → Toolbars → Category: SoulburnScripts to add buttons."
  [Open README]  [Close]
```

**Relevant Context:**
- Max registry key: `HKLM\SOFTWARE\Autodesk\3dsMax\{major}` → value `InstallDir`
- Major version map: 22=2020, 23=2021, 24=2022, 25=2023, 26=2024, 27=2025, 28=2026, 29=2027
- Max user ENU path: `%LOCALAPPDATA%\Autodesk\3dsMax\{YEAR} - 64bit\ENU\`
- Max embedded Python: `{InstallDir}\Python\python.exe`
- User presets (must NOT be deleted): `{ENU}\plugcfg\SoulburnScripts\`
- cx_Freeze docs: `python setup.py build_exe` produces a dist folder; use `--target-name` to name the exe
- tkinter ships with CPython — no additional dependencies for the installer source

---

### Sub-Task 13: Code Quality Pass — Fix All 13 Cross-Cutting Issues

**Status:** `[ ] pending`

**Intent:**
Apply the fixes identified in the Code Quality Audit to every affected script. These are structural issues that make scripts crash or behave incorrectly in Max 2025/2027, not feature changes. Sub-Task 1 (sLib.ms) handles the library fixes; this sub-task handles all 87 individual scripts.

**Expected Outcomes:**
- All 87 scripts use typed INI reads — zero `execute(getINISetting(...))` calls remain
- All references to Brazil 1/2 class literals and Mental Ray class literals removed
- All scripts use `sLibGetSafeUIPos` for window placement (no more `[400,400]`)
- All scripts use struct-based state containers instead of bare globals
- `splinePainter.ms` rewritten to use `MouseTrack` (functional in Max 2025+)
- `geometryBanger.ms` random bias fixed to `(random 1 2)`
- `objectDropper.ms` ray offset derived from scene bounds
- `edgeSelectByAngle.ms` epsilon corrected from `0.001` to `0.1`
- `layerCleaner.ms` version check boundary corrected to `<= 17.0`
- `subdivisionManager.ms` MeshSmooth path wrapped in `try/catch` with TurboSmooth fallback
- `materialMover.ms` preset list updated, dead presets removed
- `transformRandomizer.ms` seed field added
- `sLib.ms` typo on line 1187 fixed

**Todo List:**
1. Write a find/replace script (`tools/fix_ini_execute.ps1`) that scans all `.ms` files and flags every `execute(getINISetting` occurrence for manual review — generates a report of line numbers to fix
2. Add `sLibGetSafeUIPos` to `sLib.ms`; replace all `[400,400]` default positions across all scripts using the find/replace tool
3. Create struct wrappers for the 10 most-used scripts first: `nameManager`, `objectReplacer`, `transformRandomizer`, `pivotPlacer`, `modifierUtilities`, `objectPainter`, `bitmapCollector`, `instanceFinder`, `subdivisionManager`, `materialMover`
4. Fix `splinePainter.ms` — replace `thePainterInterface` with `MouseTrack` callback
5. Fix `geometryBanger.ms` line 156 — `(random 0.00 1.99) as integer` → `(random 1 2)`
6. Fix `objectDropper.ms` — replace magic `100` offsets with dynamic scene-bounds calculation
7. Fix `edgeSelectByAngle.ms` — epsilon `0.001` → `0.1`
8. Fix `layerCleaner.ms` — `< 18.0` → `<= 17.0`
9. Fix `subdivisionManager.ms` — wrap MeshSmooth path in `try/catch`
10. Fix `materialMover.ms` — replace preset list, remove Brazil/MentalRay literals
11. Fix `transformRandomizer.ms` — add seed spinner and `seed()` call before randomization loop
12. Fix `sLib.ms` typo line 1187: `udnefined` → `undefined`
13. Run the full 87-script INI-execute fix (typed reads), audit each script for remaining `execute()` uses
14. Final pass: run all scripts in Max 2025 sandbox, check for runtime errors

**Relevant Context:**
- Code Quality Audit section at the top of this file documents every fix with exact line numbers and correct code
- `sLib.ms` fixes are in Sub-Task 1 (renderer detection, new helpers) — this sub-task only covers the per-script fixes
- `splinePainter.ms` rewrite is the largest single item: ~120 lines of painter initialization replaced by ~20 lines of `MouseTrack`
- PowerShell tool for INI audit: `Select-String -Path scripts/**/*.ms -Pattern 'execute\(getINISetting'`

---

## Script Count Summary

| Category | Count |
|----------|-------|
| Original scripts | 87 |
| Marked obsolete (deleted) | 10 |
| Needs compatibility fixes | 12 |
| Still works as-is | 65 |
| New renderer-aware scripts | 6 |
| New cinecam / Atlas scripts | 6 |
| **Total active in v2.0** | **89 active** |

## New Folders — What They Are, Improvements, and How They Integrate

### `cinematic_cameras/` — Current State and Improvements

Pure Python camera-move algorithms verified on 3ds Max 2027 + V-Ray 7. Produces keyframe arrays. **No DCC imports.** 10 move types currently implemented. Each gets its **own dedicated toolbar button** in Max — not a dropdown, so artists can bind keyboard shortcuts per-move.

**Button set — `SoulburnScripts_Cinecam` category (12 unique buttons):**

| Button | Move | `cinecam.py` function |
|--------|------|----------------------|
| `cinecamArc` | Orbit at fixed radius | `arc()` |
| `cinecamDolly` | Push/pull along view axis | `dolly()` |
| `cinecamTruck` | Lateral travel | `truck()` |
| `cinecamPedestal` | Vertical rise/fall | `pedestal()` |
| `cinecamTracking` | Follow moving subject | `tracking()` |
| `cinecamPassThrough` | Hold camera, subject passes | `pass_through()` |
| `cinecamHelix` | Spiral drone dive | `helix()` |
| `cinecamWhipPan` | Snap aim to new bearing | `whip_pan()` |
| `cinecamDollyZoom` | Vertigo effect | `dolly_zoom()` |
| `cinecamHandheld` | Add wobble to existing keys | `handheld()` |
| `cinecamCheckMoves` | Validate keys in scene | `check_moves()` |
| `cinecamUI` | Open full parameter panel | all moves |

**Improvements needed in `cinecam.py`:**

*7 missing moves to add:*
- `zoom_only(start, end, subject, from_fov, to_fov)` — pure optical zoom, no camera movement
- `crane(start, end, subject, bearing_deg, distance, from_height, to_height, pan_deg)` — vertical rise with simultaneous pan; real boom arm move
- `orbit_with_lead(start, end, subject, heading, lead_deg, radius, height)` — arc that anticipates subject's movement direction
- `slide_zoom(start, end, subject, offset, bearing_deg, from_along, to_along, zoom_factor)` — lateral truck + opposing zoom
- `speed_ramp(keys, ramp_start, ramp_end, factor)` — post-process to add mid-move speed change
- `push_in(start, end, subject, bearing_deg, from_dist, to_dist, height, fov)` — slow creep that barely changes framing
- `reveal(start, end, subject, clear_bearing_deg, occluder_fn)` — arc around an obstruction to reveal subject

*Validation gaps to fix:*
- Guard `radius <= 0`, `distance <= 0` in `arc`, `dolly`, `truck`, `pedestal` (raise `MoveError`)
- Guard `NaN`/`Inf` from subject/heading callables
- Guard invalid returns from `ground()` in `clamp_above()`
- FOV range check on all non-dolly-zoom moves

*Easing additions:*
- `"bounce"` — arrive and settle (small overshoot)
- `"spring"` — overshoot then converge

*Test coverage gaps to fill:* subject callable returning NaN/Inf, radius/distance zero or negative, invalid ground callables.

---

### `tyflow_scripts/` — Current State and Improvements

Python code generator producing reviewable MaxScript for three tyFlow effect graphs. Each effect becomes its **own dedicated toolbar button** in Max.

**Button set — `SoulburnScripts_TyFlow` category (7 unique buttons):**

| Button | Effect | Status |
|--------|--------|--------|
| `tyfxSmokeGenerator` | Speed-gated tyre smoke | Existing |
| `tyfxDebrisGenerator` | PhysX crash debris burst | Existing |
| `tyfxSparksGenerator` | Titanium skid-block sparks | Existing |
| `tyfxRainGenerator` | Falling rain particles | **NEW** |
| `tyfxDustGenerator` | Ambient dust suspension | **NEW** |
| `tyfxFireGenerator` | Combustion fire particles | **NEW** |
| `tyfxFXLauncherUI` | Open full FX Launcher panel | All effects |

**Three new effect generators to add to `tyfx.py`:**

`generate_rain_script(flow_name, site_bbox, wind_bearing_deg, wind_speed_ms, site_z, end_frame, intensity)`:
- Birth over ceiling plane, speed downward + wind offset, stretched sphere shapes, Time Test deletes after fall time. Writes `out/tyfx_rain.ms`.

`generate_dust_script(flow_name, emitter_nodes, wind_bearing_deg, wind_speed_ms, site_z, end_frame, density)`:
- Low steady rate from ground, drift with wind, Scale grows over lifetime, Turbulence force for suspension. Writes `out/tyfx_dust.ms`.

`generate_fire_script(flow_name, source_nodes, contact_frame, intensity, site_z, end_frame)`:
- Burst at contact then continuous rate, upward speed, grows then deletes. `VRayLightMtl` colour ramp applied manually. Writes `out/tyfx_fire.ms`.

**Improvements to `raceanim.py`:**

1. **Expose physics constants as parameters** — `LAT_G`, `V_MIN`, `V_MAX`, `BRAKE_G`, `ACCEL_G` are module-level constants. Wrap `speed_profile()` to accept optional overrides (GT3 vs F1 vs LMP1 vs rally).

2. **Multi-lap support** — add `field_at_time_multi_lap(spine, seconds, lap_number)`. Current `field_at_time()` wraps silently at one lap with no way to track lap count.

3. **Surface condition scaling** — add `surface_condition` param to `speed_profile()`: `"dry"` (default), `"wet"` (LAT_G × 0.65), `"damp"` (LAT_G × 0.85). Rain effect then connects to car behaviour automatically.

4. **Configurable shot list** — move the hardcoded 14-shot racing sequence into `racing_shots.py` helper; `build_edit()` already accepts a `shots` parameter but the connection is not documented.

---

### `max_mcp_server/` — Current State and Improvements

Full MCP server for 3ds Max 2027. Bridge handles 15 command types. FastMCP server has 13 AI-callable tools. Needs three additions: 10 new bridge commands, a `SYSTEM_PROMPT.md` knowledge file so any AI agent connects with full context, and new data-source tools.

**Button set — `SoulburnScripts_Atlas` category (6 unique buttons):**

| Button | Function |
|--------|----------|
| `atlasBridgeStart` | Launch Atlas bridge inside Max's Python |
| `atlasBridgeStop` | Close bridge socket cleanly |
| `atlasBridgeStatus` | Ping — show port, scene, units, object count |
| `atlasCineSceneBuilder` | OSM → lit scene builder UI |
| `atlasCameraKeyWriter` | Camera key writer UI (cinecam via bridge) |
| `atlasTyFlowFXUI` | tyFlow FX launcher via bridge |

**10 new bridge commands for `atlas_max_handlers.py`:**

```python
cmd_select_objects   # select by name list / class string / material name
cmd_delete_objects   # delete by name list (with undo wrapper)
cmd_hide_show        # hide or show by name list + boolean flag
cmd_group_objects    # group selection, set group name
cmd_move_to_layer    # create layer if needed, assign objects
cmd_freeze_objects   # freeze/unfreeze by name list
cmd_get_bounds       # bounding box + vertex/face count for named node
cmd_export_file      # exportFile to FBX/OBJ/ABC/glTF with format param
cmd_import_file      # importFile from FBX/OBJ/Alembic
cmd_get_scene_stats  # total poly count, memory, object breakdown by class
```

**9 new FastMCP tools for `mcp_server.py`:**

- `atlas_select_objects(names, class_filter, material_filter)` — select scene objects
- `atlas_delete_objects(names)` — delete by name list
- `atlas_move_to_layer(names, layer_name)` — layer management
- `atlas_get_scene_stats()` — total poly count, memory, object count by class
- `atlas_export_scene(format, path, selection_only)` — FBX/OBJ/glTF export
- `atlas_import_file(path, merge)` — import external geometry
- `atlas_fetch_roads(latitude, longitude, radius_m)` — OSM roads as spline geometry in Max
- `atlas_fetch_trees(latitude, longitude, radius_m)` — OSM tree positions for scatter
- `atlas_weather_forecast(latitude, longitude, local_time)` — ECMWF open-meteo forecast for future render dates

**`SYSTEM_PROMPT.md` — Knowledge File for Any Connecting AI Agent (new file):**

Any AI agent connecting to this MCP server — Claude, GPT-4o, Gemini, local LLM — should arrive with full knowledge of the system. The server ships `max_mcp_server/SYSTEM_PROMPT.md` and exposes it as a FastMCP resource so agents can fetch it. It is also printed to stdout on server start so logs capture it.

Required sections:
```
# Atlas MCP Server — 3ds Max AI Agent Knowledge Base

## Scene Coordinate System
  +X east, +Y true north, +Z up. All units: metres.
  Origin = site lat/lon. Use atlas_solar_position to verify shadow bearing first.

## All MCP Tools  (auto-generated from docstrings — always current)

## Bridge Commands Reference  (all cmd_* handlers with parameter schemas)

## SoulBurn Scripts Available in Max
  87 scripts across 8 categories. Invoke any via:
  bridge.maxscript("nameManagerUI()")  [requires ATLAS_ALLOW_MAXSCRIPT=1]

## Renderer Detection
  sLibWhatsCurrentRenderer() → "vray" | "arnold" | "corona" | "scanline"
  Material classes: VRayMtl, Arnold_Standard_Surface, CoronaMtl, PhysicalMaterial

## tyFlow Effects
  atlas_tyre_smoke, atlas_crash_debris, atlas_crash_sparks
  + new: rain, dust, fire (after v2.0 additions)

## Cinematic Camera Moves (17 total after additions, with parameter reference)

## Common Workflows
  Golden-hour scene:   atlas_solar_position → atlas_build_scene → atlas_place_camera → atlas_render
  Add tyre smoke:      atlas_tyre_smoke(emitter_nodes=[...], spine_json=..., execute=True)
  Dolly zoom move:     atlas_camera_key_writer(move="dolly_zoom", from_dist=50, to_dist=10, from_fov=35)

## Error Handling and Limitations
  max_unavailable: Max not running or bridge not started.
  ATLAS_ALLOW_MAXSCRIPT=1 required for tyFlow/SoulBurn script execution.
  V-Ray 7 class names only — V-Ray ≤4 class names cause hard errors.
```

## Installation Design

The v2.0 release ships `installer/SoulburnScripts_v2_Setup.exe` — a self-contained Windows installer with no prerequisites. See Sub-Task 12 for the full spec. The install mapping it performs is:

```
SoulburnScripts_v2_Setup.exe  (auto-detects Max via registry)
  ├── scripts/SoulburnScripts/   → {ENU}\scripts\SoulburnScripts\
  │     includes lib/cinecam.py, lib/tyfx.py, lib/raceanim.py, lib/atlas/
  ├── MacroScripts/*.mcr         → {ENU}\scripts\Startup\
  ├── UI_ln/Icons/               → {ENU}\UI_ln\Icons\
  └── UI_ln/IconsDark/           → {ENU}\UI_ln\IconsDark\
```

Where `{ENU}` = `%LOCALAPPDATA%\Autodesk\3dsMax\{YEAR} - 64bit\ENU` for each selected version.

The installer optionally installs Python bridge dependencies (`PySide6`, `fastmcp`, `pandas`, `shapely`) into Max's own embedded Python. The SoulBurn `.ms` scripts themselves have no pip dependencies.

## Button / Toolbar Integration

Every new script gets buttons in Max via the same mechanism as the original pack:

1. **MacroScript registration** in `SoulburnScripts.mcr` — one `MacroScript` block per script, in category `"SoulburnScripts"`, with paired Default + UI macros
2. **Icon files** in `UI_ln/Icons/` (16px and 24px, `.bmp`) and `UI_ln/IconsDark/` for dark theme
3. **Adding to toolbar** — user drags from Customize > Toolbars > Category: SoulburnScripts, exactly as all 87 original scripts work today
4. **New category** — Atlas scripts (bridge launcher, scene builder, camera key writer) use category `"SoulburnScripts_Atlas"` to keep them separate in the Customize dialog
5. **New category** — tyFlow scripts use category `"SoulburnScripts_TyFlow"`
6. **New category** — Cinematic camera scripts use category `"SoulburnScripts_Cinecam"`

This means a user can build three focused toolbars:
- **SoulburnScripts** — all 77 core productivity scripts (original + updated)
- **SoulburnScripts_Cinecam** — 1 script, 10 move types via dropdown
- **SoulburnScripts_TyFlow** — 1 script, 3-tab FX launcher
- **SoulburnScripts_Atlas** — 3 scripts: bridge launcher, scene builder, camera key writer
