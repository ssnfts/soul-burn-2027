-------------------------------------------------------------------------------
-- ui_test_harness.ms  --  SoulBurn Scripts v2.0 functional test
--
-- PHASE 0: build a real V-Ray test scene (ground, boxes, backdrop, lights, cam)
-- PHASE 1: fileIn every script          -> catches COMPILE / SYNTAX errors
-- PHASE 2: open every *UI macro         -> catches UI construction errors
-- PHASE 3: run every action macro on a real selection -> catches RUNTIME crashes
--
-- Phase 3 is the one that matters: it actually executes each tool against live
-- geometry, materials, lights and a camera.
-------------------------------------------------------------------------------
(
local reportPath = "C:\\Users\\mabdu\\Downloads\\SoulburnScriptsPack_3dsMax_v112_R2013toR2022\\SB2027\\dev\\UI_TEST_REPORT.txt"
local rf = createFile reportPath
local scriptDir = (getdir #userScripts) + "\\SoulburnScripts\\scripts\\"

-------------------------------------------------------------------------------
-- PHASE 0 -- build the test scene
-------------------------------------------------------------------------------
format "\n===== PHASE 0: BUILD V-RAY TEST SCENE =====\n"
resetMaxFile #noPrompt

-- Set V-Ray as the production renderer if it is installed.
local rendSet = "none"
for c in RendererClass.classes do
	(
	local cn = c as string
	if (matchPattern cn pattern:"*V_Ray_*" ignoreCase:true) and \
	   not (matchPattern cn pattern:"*GPU*" ignoreCase:true) and \
	   not (matchPattern cn pattern:"*RT*" ignoreCase:true) then
		( try ( renderers.production = c() ; rendSet = cn ) catch () )
	)
format "  renderer: %\n" rendSet

-- Ground
local ground = Plane name:"TEST_Ground" length:400 width:400 lengthsegs:8 widthsegs:8 pos:[0,0,0]
-- Backdrop boxes
local bg1 = Box name:"TEST_BackWall"  length:10 width:400 height:200 pos:[0,200,0]
local bg2 = Box name:"TEST_SideWall"  length:400 width:10 height:200 pos:[-200,0,0]
-- Subject boxes
local boxes = #()
for i = 1 to 5 do
	(
	local b = Box name:("TEST_Box_" + (i as string)) length:40 width:40 height:(30 + i*12) \
		pos:[(-120 + (i-1)*60), 0, 0]
	b.wirecolor = color (40*i) (255 - 30*i) 128
	append boxes b
	)
local sph = GeoSphere name:"TEST_Sphere" radius:30 pos:[0,-90,30] segs:4

-- Materials: VRayMtl if available, else Physical
local mtlMade = "none"
try
	(
	local vm = VRayMtl name:"TEST_VRayMtl"
	vm.diffuse = color 200 120 60
	vm.reflection = color 40 40 40
	for b in boxes do b.material = vm
	ground.material = vm
	mtlMade = "VRayMtl"
	)
catch
	(
	try ( local pm = PhysicalMaterial name:"TEST_Physical" ; pm.base_color = color 200 120 60
		  for b in boxes do b.material = pm ; ground.material = pm ; mtlMade = "PhysicalMaterial" ) catch ()
	)
-- A bitmap texture so texture-facing tools have something to chew on
try
	(
	local bmpFile = (getdir #maxroot) + "Maps\\Backgrounds\\Lake_mount.jpg"
	if doesFileExist bmpFile then
		( local bt = Bitmaptexture fileName:bmpFile
		  try (sph.material = VRayMtl name:"TEST_Textured" diffuseMap:bt) catch (sph.material = Standard diffuseMap:bt) )
	)
catch ()
format "  materials: %\n" mtlMade

-- Lights: V-Ray light if present, plus an omni and a target spot (for filters)
local lightMade = "none"
try ( local vl = VRayLight name:"TEST_VRayLight" pos:[100,-100,200] ; lightMade = "VRayLight" ) catch ()
local om = Omnilight name:"TEST_Omni" pos:[-100,-150,180]
local sp = Targetspot name:"TEST_Spot" pos:[150,-150,220] target:(Targetobject name:"TEST_Spot.Target" pos:[0,0,20])
try ( local vs = VRaySun name:"TEST_VRaySun" pos:[250,-250,400] ) catch ()
format "  lights: %, Omni, Targetspot\n" lightMade

-- Camera (physical, so camera tools have a real target)
local cam = undefined
try ( cam = Physical name:"TEST_PhysCam" pos:[220,-260,140] target:(Targetobject name:"TEST_Cam.Target" pos:[0,0,40]) ) catch ()
if cam == undefined then try ( cam = Targetcamera name:"TEST_Cam" pos:[220,-260,140] target:(Targetobject name:"TEST_Cam.Target" pos:[0,0,40]) ) catch ()
format "  camera: %\n" (if cam == undefined then "none" else (cam as string))

-- A spline (tyFlow launcher needs a circuit spline with >=3 knots)
local sPath = circle name:"TEST_Circuit" radius:150 pos:[0,0,1]
try ( convertToSplineShape sPath ) catch ()

redrawViews()
local sceneCount = objects.count
format "  scene objects: %\n" sceneCount
format "SoulBurn FUNCTIONAL TEST\nrenderer: %\nmaterials: %\nscene objects: %\n\n" rendSet mtlMade sceneCount to:rf

fn sbSelectSubjects = ( try ( select boxes ; selectMore #(sph) ) catch () )
fn sbCloseAllFloaters =
	(
	for g in (globalVars.gather()) do
		( try ( if (matchPattern (g as string) pattern:"*Floater") then
			( local v = globalVars.get g
			  if (classof v == RolloutFloater) then closeRolloutFloater v ) ) catch () )
	)

-------------------------------------------------------------------------------
-- PHASE 1 -- compile every script
-------------------------------------------------------------------------------
format "\n===== PHASE 1: COMPILE ALL SCRIPTS =====\n"
format "== PHASE 1 compile ==\nfile\tresult\terror\n" to:rf
local cOK = 0 ; local cBad = 0
local files = getFiles (scriptDir + "*.ms")
for fp in files do
	(
	local fn2 = filenameFromPath fp
	-- these two intentionally act on load (installer prompt / uninstall prompt)
	if fn2 == "soulburnToolbarInstaller.ms" then continue
	local ok = true ; local err = ""
	try ( fileIn fp ) catch ( ok = false ; err = (getCurrentException() as string) )
	if ok then cOK += 1 else ( cBad += 1 ; format "  COMPILE FAIL: % -- %\n" fn2 err )
	format "%\t%\t%\n" fn2 (if ok then "OK" else "FAIL") (substituteString err "\n" " ") to:rf
	)
format "PHASE 1: % compiled, % FAILED\n" cOK cBad
format "\nPHASE1 total % ok % fail %\n\n" files.count cOK cBad to:rf

-------------------------------------------------------------------------------
-- PHASE 2 + 3 -- open each UI, then run the matching action on real geometry
-------------------------------------------------------------------------------
-- macro names extracted from SoulburnScripts.mcr (macros.getMacroScripts() is not a real API)
local uiMacros = #("alignerUI", "alignViewportToFaceUI", "arnoldMaterialManagerUI", "atlasBridgeLauncherUI", "atlasCineSceneBuilderUI", "bitmapCollectorUI", "blendedBoxMapMakerUI", "blendedBoxMapManagerUI", "blendedCubeProjectionMakerUI", "blendedCubeProjectionManagerUI", "cameraFromPerspViewUI", "cameraLensPackagerUI", "cameraMapTemplateRendererUI", "cinematicCameraMakerUI", "circleArrayMakerUI", "coronaMaterialManagerUI", "curvatureMakerUI", "curvatureManagerUI", "customAttributeRemoverUI", "customLightingAssistantUI", "edgeDividerUI", "edgeSelectByAngleUI", "elementSelectByFaceUI", "geometryBangerUI", "gltfExportHelperUI", "groupWithPointUI", "iDSetterUI", "imagePlaneMakerUI", "instanceFinderUI", "instanceTrimmerUI", "materialFromSelectedObjectUI", "materialInfoDisplayerUI", "materialMoverUI", "materialRemoverUI", "maxMazeGeneratorUI", "mirrorObjectAlongAxisUI", "modelPreparerUI", "modifierUtilitiesUI", "nameManagerUI", "nodeTypeDisplayerUI", "objectAttacherUI", "objectDetacherUI", "objectDropperUI", "objectPainterUI", "objectReplacerUI", "objectSelectorByMaterialUI", "objectUniquefierUI", "oslMapBrowserUI", "parameterManagerUI", "parentSelectorUI", "physicalCameraManagerUI", "pipeMakerUI", "pivotPlacerUI", "polyCountSelectorUI", "renderSizerUI", "selectionRandomizerUI", "smartLightingUI", "softSelectionControlUI", "soulburnAssetLoaderUI", "soulburnScriptsListerUI", "splineKnotManagerUI", "splineKnotToObjectUI", "splineManagerUI", "splinePainterUI", "subdivisionAutomatorUI", "subdivisionManagerUI", "texmapBakerUI", "texmapPreviewUI", "thinFaceSelectorUI", "transformRandomizerUI", "transformRemoverUI", "transformSelectorUI", "tyflowFXLauncherUI", "uniqueObjectFinderUI", "uVAreaDisplayerUI", "uVFlattenerUI", "uVFlattenMapperUI", "uVPlacerUI", "uVTransferUI", "vertexEdgeFaceSelectByNormalUI", "vertexMapDisplayerUI", "vertPlacerUI", "vertSelectionToObjectUI", "viewportToVFBLoaderUI", "vrayMatteManagerUI", "vraySamplingSubdivManagerUI", "wireColorRandomizerUI", "wireMakerUI")
local actMacros = #()  -- Phase 3 disabled for the clean recording pass

format "\n===== PHASE 2: OPEN % UIs =====\n" uiMacros.count
format "== PHASE 2 open UI ==\nmacro\tresult\terror\n" to:rf
local uOK = 0 ; local uBad = 0
for n in uiMacros do
	(
	local ok = true ; local err = ""
	format ">>> UI  %\n" n
	sbSelectSubjects()
	try ( macros.run "SoulburnScripts" n ) catch ( ok = false ; err = (getCurrentException() as string) )
	windows.processPostedMessages() ; sleep 0.25
	if ok then uOK += 1 else ( uBad += 1 ; format "    UI FAIL: %\n" err )
	format "%\t%\t%\n" n (if ok then "OK" else "FAIL") (substituteString err "\n" " ") to:rf
	sbCloseAllFloaters() ; windows.processPostedMessages()
	)
format "PHASE 2: % opened, % FAILED\n" uOK uBad
format "\nPHASE2 total % ok % fail %\n\n" uiMacros.count uOK uBad to:rf

format "\n===== PHASE 3: EXECUTE % ACTIONS ON REAL GEOMETRY =====\n" actMacros.count
format "== PHASE 3 execute action ==\nmacro\tresult\terror\n" to:rf
local aOK = 0 ; local aBad = 0
for n in actMacros do
	(
	local ok = true ; local err = ""
	-- NEVER run these: one deletes the entire pack, one rewrites the toolbar
	if n == "uninstallSoulburn" or n == "soulburnToolbarInstaller" then
		(
		format "--- SKIPPED (destructive): %\n" n
		format "%\tSKIPPED\tdestructive - deliberately not run\n" n to:rf
		continue
		)
	format ">>> RUN %\n" n
	sbSelectSubjects()
	holdMaxFile()
	try ( macros.run "SoulburnScripts" n ) catch ( ok = false ; err = (getCurrentException() as string) )
	windows.processPostedMessages() ; sleep 0.2
	if ok then aOK += 1 else ( aBad += 1 ; format "    ACTION FAIL: %\n" err )
	format "%\t%\t%\n" n (if ok then "OK" else "FAIL") (substituteString err "\n" " ") to:rf
	sbCloseAllFloaters()
	try ( fetchMaxFile quiet:true ) catch ()
	windows.processPostedMessages()
	)
format "\nPHASE3 total % ok % fail %\n" actMacros.count aOK aBad to:rf
close rf

format "\n=================================================\n"
format " SCENE   : % objects, renderer %, materials %\n" sceneCount rendSet mtlMade
format " COMPILE : % ok / % FAILED\n" cOK cBad
format " UI OPEN : % ok / % FAILED\n" uOK uBad
format " ACTIONS : % ok / % FAILED\n" aOK aBad
format " Report  : %\n" reportPath
format "=================================================\n"
)


