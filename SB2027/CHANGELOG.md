# Changelog — SoulBurn Scripts Pack

---

## v2.00 — 2025-05-01 (SoulBurn 2027 Update)

### New Scripts

- **`arnoldMaterialManager.ms`** — Batch-manage Arnold Standard Surface material properties (subdivision, displacement, opacity, cast shadows) across selected objects
- **`coronaMaterialManager.ms`** — Batch-manage CoronaMtl properties (displacement, glossiness, GI exclusion) across selected objects
- **`physicalCameraManager.ms`** — Batch-control ISO, f-stop, shutter speed, focal length, and white balance on Physical Cameras
- **`oslMapBrowser.ms`** — Browse .osl / .oso map files from Max OSL directories and assign to material editor slot
- **`gltfExportHelper.ms`** — Pre-flight validation (UV channel 1, material compatibility, scale) + guided glTF/glb export (Max 2023+)
- **`cinematicCameraMaker.ms`** — Generate 10 cinematic camera moves (arc, dolly, truck, pedestal, tracking, pass-through, helix, whip pan, handheld, dolly zoom) powered by cinecam.py
- **`tyflowFXLauncher.ms`** — Three-tab UI for generating tyFlow tyre smoke / crash debris / crash sparks scripts via tyfx.py
- **`atlasBridgeLauncher.ms`** — Start/Stop/Ping the Atlas MCP bridge for AI-driven scene control
- **`atlasCineSceneBuilder.ms`** — Build full cinematic scenes from lat/lon coordinates via Atlas bridge (OSM buildings, terrain, sun, camera, render)

### sLib.ms Changes (v1.50 → v2.00)

- **`sLibWhatsCurrentRenderer()`** — Completely rewritten using `matchPattern` on class name string. No more fragile hardcoded class IDs. Returns `"arnold"`, `"vray"`, `"corona"`, `"scanline"`, or `"unknown"`
- **`sLibGetSafeUIPos(w, h)`** — NEW. Returns `[x, y]` centred on screen. Handles 4K and multi-monitor. Replaces hardcoded `[400,400]`
- **`sLibAtlasBridgeCall(cmdName, paramsObj)`** — NEW. Sends JSON command to Atlas bridge via .NET TCP socket
- **`sLibGetArnoldLightMaps()`** — NEW. Collects maps from Arnold lights
- **`sLibGetCoronaLightMaps()`** — NEW. Collects maps from CoronaLight/CoronaSun
- **`sLibGetAllPhysicalMaterials()`** — NEW. Collects all Physical Material instances from scene
- **`sLibArnoldTest()`** — NEW. Returns true if Arnold renderer is available
- **`sLibCoronaTest()`** — NEW. Returns true if Corona renderer is available
- **`sLibBrazil1Test()`** — Now always returns `false` (Brazil 1 removed)
- **`sLibBrazil2Test()`** — Now always returns `false` (Brazil 2 removed)
- **`sLibFileExist(f)`** — Rewritten using `doesFileExist` (no glob false-positives on special characters)
- **`sLibMakeStringLowercase(s)`** — Now uses built-in `toLower` (faster, handles Unicode)
- **`sLibMakeStringUppercase(s)`** — Now uses built-in `toUpper` (faster, handles Unicode)
- **`sLibGetAllBrazilSkylightMaps()`** — Now returns empty array (Brazil no longer supported)
- **`sLibGetAllProjectorLightMaps()`** — Brazil_Light and B2_Main_Light references removed; wrapped in `try/catch`
- **`sLibCopyAndPasteLayerFromNodeToNode()`** — Fixed typo: `return udnefined` → `return undefined`
- Version bump: `v1.50` → `v2.00`

### Script Bug Fixes

| Script | Fix |
|--------|-----|
| `splinePainter.ms` | Completely rewritten to use `MouseTrack` instead of removed `thePainterInterface` (Max 2020+). Paint callback: `sPAMouseTrackCallback`. Right-click or Escape to end paint session |
| `geometryBanger.ms` | Fixed biased random distribution: `(random 0.00 1.99) as integer` → `(random 1 2)` (both occurrences) |
| `objectDropper.ms` | Fixed magic `+100`/`-100` ray offsets. Now derives `rayOffset` from scene bounding box diagonal × 0.5 — works at any scale |
| `edgeSelectByAngle.ms` | Fixed epsilon: `0.001` (nearly zero in degrees) → `0.1` degree tolerance |
| `subdivisionManager.ms` | MeshSmooth path wrapped in `try/catch`; falls back to TurboSmooth with user notification (Max 2025+) |
| `materialMover.ms` | Removed Brazil 1/2 and Mental Ray preset literals (crash on Max 2022+). Presets updated: Standard, Physical, VRay, Arnold, Corona, glTF. Validation checks updated accordingly |
| `transformRandomizer.ms` | Added `tRASeedValue` spinner (default -1 = random each run). `seed()` called before each randomization loop. INI load/save updated to typed reads |

### MacroScripts (SoulburnScripts.mcr)

- Version bumped: `v1.56` → `v2.00`
- Added Default + UI macros for all 9 new scripts
- All new macros use individual `Icon:#(...)` entries for unique toolbar buttons

---

## v1.12 — 2017-11-16 (Original Release)

Last version by Neil Blevins. Tested on 3ds Max R2013–R2022.

See http://www.neilblevins.com/art_assets/scripts/soulburnscripts_for_3dsmax.htm for original documentation.
