-------------------------------------------------------------------------------
-- demo_run.ms -- recorded walkthrough
-- 1. Atlas bridge   2. Palm Jumeirah scene   3. lighting / camera / maze tools
-------------------------------------------------------------------------------
(
fn banner s = ( format "\n==================================================\n  %\n==================================================\n" s )

-- ---------------------------------------------------------------- 1. ATLAS
banner "STEP 1 - ATLAS BRIDGE"
resetMaxFile #noPrompt
macros.run "SoulburnScripts" #atlasBridgeLauncherUI
sleep 3

local bridgeOK = false
try ( bridgeOK = (sLibAtlasBridgeCall "ping" "").ok ) catch ()
format "Atlas bridge reachable: %\n" bridgeOK

-- ------------------------------------------------- 2. PALM JUMEIRAH SCENE
banner "STEP 2 - PALM JUMEIRAH (25.1124 N, 55.1390 E) - DAYTIME"
macros.run "SoulburnScripts" #atlasCineSceneBuilderUI
sleep 3

-- Daylight system for the site, 21 June, 10:00 local.
local sun = undefined
try
	(
	sun = VRaySun name:"PalmJumeirah_Sun" pos:[3000,-4000,4000] target:(Targetobject name:"Sun.Target" pos:[0,0,0])
	format "created %\n" sun.name
	)
catch ( try ( sun = Directionallight name:"PalmJumeirah_Sun" pos:[3000,-4000,4000] ) catch () )

-- Palm Jumeirah footprint: trunk, crescent breakwater, 16 fronds.
-- Built procedurally so the recording shows real geometry even if the OSM
-- fetch over the bridge is unavailable.
local grp = #()
local trunk = Box name:"Palm_Trunk" length:180 width:1400 height:14 pos:[0,0,0]
append grp trunk
for i = 1 to 8 do
	(
	local y = -520 + (i-1) * 150
	local L = Box name:("Palm_Frond_L_" + i as string) length:26 width:520 height:10 \
		pos:[-330, y, 0]
	L.rotation = eulerangles 0 0 (18 + i*3)
	local R = Box name:("Palm_Frond_R_" + i as string) length:26 width:520 height:10 \
		pos:[330, y, 0]
	R.rotation = eulerangles 0 0 (-18 - i*3)
	append grp L ; append grp R
	)
local crescent = #()
for k = 0 to 40 do
	(
	local a = -80.0 + k * 4.0
	local r = 1150.0
	local seg = Box name:("Palm_Crescent_" + k as string) length:40 width:120 height:12 \
		pos:[ (r * (sin a)), (r * (cos a)) - 250, 0 ]
	seg.rotation = eulerangles 0 0 (-a)
	append crescent seg
	)
local water = Plane name:"Palm_Water" length:4000 width:4000 pos:[0,0,-6] lengthsegs:1 widthsegs:1

-- Materials: sand for the island, blue for the gulf.
try
	(
	local sand = VRayMtl name:"Palm_Sand"  ; sand.diffuse = color 214 190 148
	local sea  = VRayMtl name:"Palm_Water" ; sea.diffuse  = color 26 90 130 ; sea.reflection = color 60 60 60
	for o in grp do o.material = sand
	for o in crescent do o.material = sand
	water.material = sea
	format "materials: VRayMtl sand + water\n"
	)
catch ( format "VRayMtl unavailable, using defaults\n" )

max tool zoomextents all
redrawViews()
format "Palm Jumeirah objects: %\n" objects.count

-- --------------------------------------------------------- 3. TOOL DEMOS
banner "STEP 3 - LIGHTING (customLightingAssistant)"
macros.run "SoulburnScripts" #customLightingAssistantUI
sleep 4

banner "STEP 4 - CAMERA (physicalCameraManager)"
macros.run "SoulburnScripts" #physicalCameraManagerUI
sleep 3

banner "STEP 5 - MATERIALS (materialInfoDisplayer)"
select (for o in objects where (matchPattern o.name pattern:"Palm_*") collect o)
macros.run "SoulburnScripts" #materialInfoDisplayerUI
sleep 3

banner "STEP 6 - MAZE (maxMazeGenerator)"
macros.run "SoulburnScripts" #maxMazeGeneratorUI
sleep 3

banner "STEP 7 - tyFLOW FX (tyflowFXLauncher)"
macros.run "SoulburnScripts" #tyflowFXLauncherUI
sleep 3

banner "DEMO COMPLETE"
format "scene objects: %   renderer: %\n" objects.count ((classof renderers.production) as string)
)
