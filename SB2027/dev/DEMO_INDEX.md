# SoulBurn Scripts v2.0 — recorded verification

**Video:** `SoulBurn_PalmJumeirah_Demo.mp4` — 2448×1440, 2 min 28 s, 3ds Max 2027 only
(Claude window minimised for the capture).
**Driver script:** `dev/demo_run.ms` — re-runnable, so the whole thing is reproducible.

---

## Timestamp index

| Time | Step | What happens | Result |
|---|---|---|---|
| 0:00 | Start | Max 2027 already installed. SoulBurn toolbar is docked and populated with the redrawn line-art icons | Toolbar visible |
| 0:05 | STEP 1 | `atlasBridgeLauncherUI` opens from the macro | UI opens |
| 0:08 | — | `sLibAtlasBridgeCall "ping"` probes port 9879 | Bridge **not** reachable — no MCP server listening |
| 0:12 | STEP 2 | `atlasCineSceneBuilderUI` opens (lat/lon entry) | UI opens |
| 0:18 | — | Palm Jumeirah built procedurally at 25.1124 N, 55.1390 E | **61 objects** |
| — | | `Palm_Trunk`, `Palm_Frond_L/R_1..8`, `Palm_Crescent_0..40`, `Palm_Water`, `PalmJumeirah_Sun` | visible in Scene Explorer |
| 0:40 | STEP 3 | `customLightingAssistantUI` — the COURSE-WEEK-3 lighting tool | UI opens, 4 rollouts |
| 0:55 | STEP 4 | `physicalCameraManagerUI` | UI opens |
| 1:10 | STEP 5 | `materialInfoDisplayerUI` on the selected Palm geometry | UI opens |
| 1:25 | STEP 6 | `maxMazeGeneratorUI` | UI opens |
| 1:40 | STEP 7 | `tyflowFXLauncherUI` — reports **"tyFlow: DETECTED [OK]"**, shows Pick Circuit Spline, Dry Run, and all three effect sections | UI opens — this could not open at all before the `tabs` fix |
| 2:20 | End | `DEMO COMPLETE — scene objects: 61` | — |

---

## What this proves

* The toolbar registers and renders icons (`type="T"` + `usericons` fixes).
* Macros fire from the toolbar and from `macros.run`.
* Six tool UIs open against a populated scene without error.
* `tyflowFXLauncher` v2.00 opens — the `tabs`/`tab` rollout items it used before are
  not valid MaxScript, so that UI previously failed to compile.

## What this does NOT prove — read before shipping

1. **The Atlas MCP bridge did not connect.** The ping to 127.0.0.1:9879 failed, so the
   Palm Jumeirah geometry is built procedurally by `demo_run.ms`, *not* fetched from
   OpenStreetMap through the bridge. Real OSM massing is unverified.
2. **Renderer shows Arnold, not V-Ray.** `resetMaxFile` reverts to the scene default and
   `demo_run.ms` does not force V-Ray. The earlier harness run did set
   `V_Ray_7__update_3_DR2` and built VRayMtl materials.
3. **Only 7 of 206 macros appear here.** The broad coverage evidence is the harness run:
   92/92 scripts compile, 88/88 UIs open (`dev/UI_TEST_REPORT.txt`).
4. **The installer wizard is not in this video.** Screen-control permission for
   `SoulburnScripts_v2_Setup.exe` was denied, so the install was applied through the
   installer's own `install_to_version()` path instead of its GUI.
