# SoulBurn Scripts v2.0 — Audit Report

3ds Max 2027 · V-Ray 7 Update 3 · clean uninstall + fresh install · driven over
the Atlas MCP bridge from a separate process.

**This is not an all-clear.** Read §4.

---

## 1. Why your buttons did nothing — root cause found and fixed

`vrayMaterialLab.ms:701` failed to compile:

```
Compile error: No outer local variable references permitted here
  In line: on vMLReportPrint pressed do (for l in lines d
```

`vMLShowReport title lines` built a rollout whose handler referenced `lines`,
the enclosing function's parameter. A MaxScript rollout handler cannot close
over an outer local. That single error aborted the file, which aborted macro
registration for the pack — so **every** toolbar button became inert, not just
the V-Ray Material Lab ones.

Fixed by passing the data through a global (`vMLReportLines`). All 93 scripts
were then scanned for the same construct: **0 further instances.**

| | Before | After |
|---|---|---|
| Tools registered | toolbar dead | **235** |
| Startup | compile-error dialog | clean |

## 2. Install / uninstall

Fresh cycle performed. The uninstaller had three gaps, all fixed:

- left **1241 icons** in `usericons\` (the folder Max 2025-2027 actually reads
  legacy BMP icons from — added to `INSTALL_MAP` earlier but never to the
  uninstaller)
- left Max's **exploded per-macro `.mcr` files**, so a reinstall ran against
  stale macro definitions
- left the **toolbar "already created" flag** and `.cuix.layout`, so a
  reinstall never rebuilt the toolbar

Post-uninstall residue is now only `plugcfg\SoulburnScripts\presets\` (user
presets, deliberately preserved). Fresh install: **3848 files, 93 scripts,
1241 icons**, both startup scripts.

## 3. Verified working

| Item | Evidence |
|---|---|
| MCP bridge auto-start | listening on 127.0.0.1:9879 after launch, unattended |
| `ping` | `pong: True, protocol 2, max_version 2027` |
| `soulburn_list` | **235 tools** with descriptions + `invoke_with` contract |
| `soulburn_run` | executed `maxMazeGeneratorUI`, `vrayMaterialLabUI`; unknown names rejected |
| Renderer | `V_Ray_7__update_3_DR2` set via bridge |
| Palm Jumeirah geometry | **59 objects** — trunk, 16 fronds, 41 crescent segments, water |
| Materials | VRayMtl sand + sea, `reflection_glossiness` 0.92, bitmap in diffuse |
| Lighting | VRaySun + VRayLight dome + VRayLight plane fill |
| Camera | Physical camera, 35 mm, f/8, **animated 240-frame orbit, 13 keys**, 24 fps |
| Tools run on the live scene | `materialInfoDisplayer`, `iDSetter`, `instanceFinder`, `transformRandomizer` |

Also fixed this session: the installer's auto-start preference was written to
`{ENU}\plugcfg\...\AtlasAutoStart.ini [AtlasAutoStart] enabled`, while the
startup script reads `{ENU}\en-US\plugcfg\...\presets\atlasBridgeLauncher.ini
[atlasBridgeLauncher] aBLAutoStartValue`. Wrong directory, filename, section
and key — so ticking "auto-start" never started anything. Now written with
`configparser` into the correct section.

## 4. NOT verified — what is still open

**The 240-frame render did not run, and the .max was not saved.** Both steps sit
behind the blocker below.

**Bridge worker-thread limit.** The bridge executes jobs on a socket thread
under `pymxs.mxstoken()`. Object *creation* works (all the geometry, materials,
lights and the camera above were built that way). But calls that touch Max's
UI/notification layer fail with `Unknown MAXScript exception`:

- `resetMaxFile #noPrompt`
- `select <array>`

Because `select` fails, every selection-dependent tool then raises its own
"Please select at least one object" **modal dialog**, and a modal dialog blocks
every subsequent bridge command. That is what stalled the run twice.

Consequently these were **not** exercised: `selectionRandomizer`,
`wireColorRandomizer`, `vraySamplingSubdivManager`, `vrayMatteManager`,
`polyCountSelector`, `uniqueObjectFinder`, `objectUniquefier`, `xFormResetter`,
`materialRemover`, `nodeTypeDisplayer`.

**Tools that need interactive picking** cannot be driven headlessly at all and
were documented rather than run: `objectDropper` (ground objects registered via
its own UI), `edgeDivider` (exactly one object), `maxMazeGenerator` (an Editable
Poly grid), plus the pure-UI tools `customLightingAssistant`,
`physicalCameraManager`, `cameraLensPackager`, `vrayMaterialLabAudit`.

**Toolbar not visually reconfirmed** after this final install.

## 5. What would close it

1. Make the bridge marshal UI-touching calls to the main thread — a
   `System.Windows.Forms.Timer` pump exists in `atlas_max_bridge.py` but is not
   currently the execution path. `select` and `resetMaxFile` need it.
2. Suppress modal dialogs during automation, or set selection through a path
   that does not raise (`selectionSets`, or `execute` on the main thread).
3. Re-run `dev/sb_audit.py` — the render and save steps are already written.
