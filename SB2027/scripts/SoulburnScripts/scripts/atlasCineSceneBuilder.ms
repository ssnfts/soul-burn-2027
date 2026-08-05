-------------------------------------------------------------------------------
-- atlasCineSceneBuilder.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-- Atlas Bridge must be running (use atlasBridgeLauncher.ms)
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Drive the Atlas atlas_build_scene workflow from a SoulBurn UI panel.
-- Builds a full cinematic scene: fetches OSM buildings, terrain, places sun,
-- places camera, and renders - all via the Atlas MCP bridge.
-- Bridge must be started first using atlasBridgeLauncher.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global atlasCineSceneBuilderDefaults
global atlasCineSceneBuilderUI

global aCBCloseOpenUI
global aCBHelp
global aCBLoadDef
global aCBSaveDef
global aCBDefineUI
global aCBRollout
global aCBFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
aCBLatValue = 51.5074
aCBLonValue = -0.1278
aCBHourValue = 14
aCBMinuteValue = 0
aCBRadiusValue = 200.0
aCBTerrainValue = true
aCBResetSceneValue = false
aCBPosValue = sLibGetSafeUIPos 310 380

-- Functions

fn aCBBridgeCmd cmd params =
	(
	local result = sLibAtlasBridgeCall cmd params
	if not result.ok then
		MessageBox ("Bridge error for '" + cmd + "':\n" + result.result) title:"atlasCineSceneBuilder"
	return result
	)

fn atlasCineSceneBuilderDefaults = (aCBLoadDef())
fn atlasCineSceneBuilderUI = (aCBLoadDef(); aCBCloseOpenUI aCBPosValue)

fn aCBCloseOpenUI pos =
	(
	if aCBFloater != undefined then CloseRolloutFloater aCBFloater
	aCBDefineUI()
	aCBFloater = newRolloutFloater "atlasCineSceneBuilder v1.00" 310 380 pos.x pos.y
	addRollout aCBRollout aCBFloater
	)

fn aCBHelp =
	(
	MessageBox "atlasCineSceneBuilder: Build a cinematic scene via the Atlas MCP bridge.\n\n1. Start Atlas bridge with atlasBridgeLauncher.\n2. Set lat/lon for location.\n3. Use buttons to build step-by-step or click Build Scene for all-in-one.\n\nRequires Atlas bridge on port 9879." title:"atlasCineSceneBuilder Help"
	)

fn aCBLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	f = presetDir + "atlasCineSceneBuilder.ini"
	if (sLibFileExist f == true) then
		(
		aCBLatValue = (getINISetting f "atlasCineSceneBuilder" "aCBLatValue") as float
		aCBLonValue = (getINISetting f "atlasCineSceneBuilder" "aCBLonValue") as float
		aCBHourValue = (getINISetting f "atlasCineSceneBuilder" "aCBHourValue") as integer
		aCBMinuteValue = (getINISetting f "atlasCineSceneBuilder" "aCBMinuteValue") as integer
		aCBRadiusValue = (getINISetting f "atlasCineSceneBuilder" "aCBRadiusValue") as float
		aCBTerrainValue = (getINISetting f "atlasCineSceneBuilder" "aCBTerrainValue") == "true"
		aCBResetSceneValue = (getINISetting f "atlasCineSceneBuilder" "aCBResetSceneValue") == "true"
		aCBPosValue = sLibGetINIPoint2 f "atlasCineSceneBuilder" "aCBPosValue" (sLibGetSafeUIPos 310 380)
		if aCBLatValue == 0.0 then aCBLatValue = 51.5074
		if aCBRadiusValue == 0.0 then aCBRadiusValue = 200.0
		)
	else
		(
		aCBLatValue = 51.5074; aCBLonValue = -0.1278
		aCBHourValue = 14; aCBMinuteValue = 0
		aCBRadiusValue = 200.0; aCBTerrainValue = true; aCBResetSceneValue = false
		aCBPosValue = sLibGetSafeUIPos 310 380
		)
	)

fn aCBSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	f = presetDir + "atlasCineSceneBuilder.ini"
	if (sLibFileExist f == true) then deleteFile f
	setINISetting f "atlasCineSceneBuilder" "aCBLatValue" (aCBLatValue as string)
	setINISetting f "atlasCineSceneBuilder" "aCBLonValue" (aCBLonValue as string)
	setINISetting f "atlasCineSceneBuilder" "aCBHourValue" (aCBHourValue as string)
	setINISetting f "atlasCineSceneBuilder" "aCBMinuteValue" (aCBMinuteValue as string)
	setINISetting f "atlasCineSceneBuilder" "aCBRadiusValue" (aCBRadiusValue as string)
	setINISetting f "atlasCineSceneBuilder" "aCBTerrainValue" (aCBTerrainValue as string)
	setINISetting f "atlasCineSceneBuilder" "aCBResetSceneValue" (aCBResetSceneValue as string)
	setINISetting f "atlasCineSceneBuilder" "aCBPosValue" (aCBFloater.pos as string)
	)

-- UI

fn aCBDefineUI =
	(
	rollout aCBRollout "atlasCineSceneBuilder"
		(
		group "Location"
			(
			spinner aCBLatSpinner "Latitude: " range:[-90.0,90.0,aCBLatValue] fieldWidth:80 type:#float align:#right
			spinner aCBLonSpinner "Longitude: " range:[-180.0,180.0,aCBLonValue] fieldWidth:80 type:#float align:#right
			spinner aCBRadiusSpinner "Build Radius (m): " range:[10.0,10000.0,aCBRadiusValue] fieldWidth:70 type:#float align:#right
			)
		group "Time"
			(
			spinner aCBHourSpinner "Hour (0-23): " range:[0,23,aCBHourValue] fieldWidth:50 type:#integer align:#right
			spinner aCBMinuteSpinner "Minute: " range:[0,59,aCBMinuteValue] fieldWidth:50 type:#integer align:#right
			)
		group "Options"
			(
			checkbox aCBTerrainCheckbox "Include Terrain" checked:aCBTerrainValue align:#left
			checkbox aCBResetSceneCheckbox "Reset Scene Before Build" checked:aCBResetSceneValue align:#left
			)

		on aCBLatSpinner changed v do aCBLatValue = v
		on aCBLonSpinner changed v do aCBLonValue = v
		on aCBRadiusSpinner changed v do aCBRadiusValue = v
		on aCBHourSpinner changed v do aCBHourValue = v
		on aCBMinuteSpinner changed v do aCBMinuteValue = v
		on aCBTerrainCheckbox changed s do aCBTerrainValue = s
		on aCBResetSceneCheckbox changed s do aCBResetSceneValue = s

		group "Build Steps"
			(
			button aCBFetchPreviewBtn "Fetch Preview" width:130 align:#left across:2
			button aCBBuildSceneBtn "Build Scene (All)" width:130 align:#right
			button aCBSetSunBtn "Set Sun" width:80 align:#left across:3
			button aCBPlaceCamBtn "Place Camera" width:100 align:#center
			button aCBRenderBtn "Render" width:80 align:#right
			)
		on aCBFetchPreviewBtn pressed do
			aCBBridgeCmd "fetch_context" ("\"lat\":" + (aCBLatValue as string) + ",\"lon\":" + (aCBLonValue as string))
		on aCBBuildSceneBtn pressed do
			aCBBridgeCmd "build_scene" ("\"lat\":" + (aCBLatValue as string) + ",\"lon\":" + (aCBLonValue as string) + ",\"radius\":" + (aCBRadiusValue as string) + ",\"terrain\":" + (if aCBTerrainValue then "true" else "false") + ",\"reset\":" + (if aCBResetSceneValue then "true" else "false"))
		on aCBSetSunBtn pressed do
			aCBBridgeCmd "set_sun" ("\"hour\":" + (aCBHourValue as string) + ",\"minute\":" + (aCBMinuteValue as string) + ",\"lat\":" + (aCBLatValue as string) + ",\"lon\":" + (aCBLonValue as string))
		on aCBPlaceCamBtn pressed do
			aCBBridgeCmd "place_camera" ("\"lat\":" + (aCBLatValue as string) + ",\"lon\":" + (aCBLonValue as string))
		on aCBRenderBtn pressed do
			aCBBridgeCmd "render" ""

		button aCBHelpButton "Help" width:80 align:#left across:2
		button aCBSaveDefButton "SaveDef" width:80 align:#right
		on aCBHelpButton pressed do aCBHelp()
		on aCBSaveDefButton pressed do aCBSaveDef()
		)
	)
)
-------------------------------------------------------------------------------
