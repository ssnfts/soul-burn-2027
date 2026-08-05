-------------------------------------------------------------------------------
-- maxMazeGenerator.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-- scripts/SoulburnScripts/lib/maze/max_maze.py
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Generates a maze on any Editable Poly using a recursive back-tracker over
-- the mesh's own face-adjacency graph. Optional braiding adds loops, and the
-- wall faces can be inset and extruded to produce raised 3D walls.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a grid (Plane with Length/Width Segs), convert it to Editable Poly,
-- select it, then press "Generate Maze On Selection". Raise "Wall Height" for
-- 3D walls, or set it to 0 for a flat edge-selection preview. "Braid/Loops"
-- above 0 removes dead ends to produce a non-perfect maze.
--
-- Note: face lookup is O(edges), so meshes above roughly 10k faces get slow.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global maxMazeGeneratorDefaults
global maxMazeGeneratorUI

global mMGCloseOpenUI
global mMGGenerate
global mMGFlatten
global mMGRunMaze
global mMGHelp
global mMGLoadDef
global mMGSaveDef
global mMGDefineUI
global mMGRollout
global mMGFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
mMGSeedValue = 42
mMGBraidValue = 0.0
mMGDepthValue = 2.0
mMGWallWidthValue = 0.3
mMGAutoConvertValue = true
mMGPosValue = sLibGetSafeUIPos 280 300

global mMGLastResult = "Ready."

-- Functions

fn mMGRunMaze seed braid depth wallWidth autoConvert =
	(
	-- Writes a small temp .py that imports max_maze without triggering its
	-- __main__ auto-run, calls run_maze() with the UI values, and hands the
	-- result back through a MaxScript global.
	local mazePy = ((getdir #userScripts) + "\\SoulburnScripts\\lib\\maze\\max_maze.py")
	if not (doesFileExist mazePy) then
		(
		MessageBox ("max_maze.py not found.\nExpected:\n" + mazePy + "\n\nRe-run the SoulBurn installer.") title:"maxMazeGenerator"
		return false
		)

	if selection.count == 0 then
		(
		MessageBox "Select a mesh or Editable Poly object first." title:"maxMazeGenerator"
		return false
		)

	local obj = selection[1]
	if autoConvert and (classof obj != Editable_Poly) then
		(
		if not (canConvertTo obj Editable_Poly) then
			(
			MessageBox ((obj.name) + " cannot be converted to Editable Poly.") title:"maxMazeGenerator"
			return false
			)
		convertTo obj Editable_Poly
		)
	if classof obj != Editable_Poly then
		(
		MessageBox ((obj.name) + " is not an Editable Poly.\nEnable \"Auto-convert to Editable Poly\" or convert it yourself.") title:"maxMazeGenerator"
		return false
		)

	global mMGLastResult = "Running..."
	local tmpPy = (getDir #temp) + "\\sb_maze_run.py"
	local f = openFile tmpPy mode:"w"
	if f == undefined then
		(
		MessageBox ("Could not write temp file:\n" + tmpPy) title:"maxMazeGenerator"
		return false
		)
	format "import importlib.util\n" to:f
	format "from pymxs import runtime as rt\n" to:f
	format "spec = importlib.util.spec_from_file_location('sb_max_maze', r'%')\n" mazePy to:f
	format "mod = importlib.util.module_from_spec(spec)\n" to:f
	format "spec.loader.exec_module(mod)\n" to:f
	format "try:\n" to:f
	format "    res = mod.run_maze(seed=%, braid=%, depth=%, wall_width=%)\n" seed braid depth wallWidth to:f
	format "    if res is None:\n" to:f
	format "        rt.mMGLastResult = 'Aborted - see Listener.'\n" to:f
	format "    else:\n" to:f
	format "        rt.mMGLastResult = 'Done - %%d passages, %%d wall faces.' %% res\n" to:f
	format "except Exception as e:\n" to:f
	format "    rt.mMGLastResult = 'Error: ' + str(e)\n" to:f
	close f

	-- theHold wrapping lets the artist Ctrl-Z the whole maze in one step.
	theHold.Begin()
	local ok = true
	try
		(
		python.ExecuteFile tmpPy
		)
	catch
		(
		ok = false
		global mMGLastResult = ("Error: " + (getCurrentException() as string))
		)
	if ok then theHold.Accept "maxMazeGenerator" else theHold.Cancel()

	try (deleteFile tmpPy) catch ()
	return ok
	)

fn mMGGenerate seed braid depth wallWidth autoConvert =
	(
	mMGRunMaze seed braid depth wallWidth autoConvert
	)

fn mMGFlatten autoConvert =
	(
	-- depth 0 skips the extrude entirely, leaving just the maze edge selection.
	mMGRunMaze mMGSeedValue mMGBraidValue 0.0 0.0 autoConvert
	)

fn maxMazeGeneratorDefaults =
	(
	mMGLoadDef()
	mMGGenerate mMGSeedValue mMGBraidValue mMGDepthValue mMGWallWidthValue mMGAutoConvertValue
	)

fn maxMazeGeneratorUI =
	(
	mMGLoadDef()
	mMGCloseOpenUI mMGPosValue
	)

fn mMGCloseOpenUI pos =
	(
	if mMGFloater != undefined then CloseRolloutFloater mMGFloater
	mMGDefineUI()
	mMGFloater = newRolloutFloater "maxMazeGenerator v1.00" 280 300 pos.x pos.y
	addRollout mMGRollout mMGFloater
	)

fn mMGHelp =
	(
	MessageBox "maxMazeGenerator: Builds a maze on an Editable Poly.\n\nSeed: Same seed always gives the same maze.\nBraid/Loops: 0 = perfect maze (no loops), 1 = maximum loops.\nWall Height: World units to extrude wall faces. 0 = flat preview.\nWall Inset Fraction: 0.0-0.5, controls how wide the passages are.\n\nMake a Plane with Length/Width Segs, convert to Editable Poly,\nselect it, then press Generate.\n\nPerformance: face lookup is O(edges). Meshes above ~10k faces\nwill be slow." title:"maxMazeGenerator Help"
	)

fn mMGLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	mMGInputFilename = presetDir + "maxMazeGenerator.ini"
	if (sLibFileExist mMGInputFilename == true) then
		(
		mMGSeedValue = sLibGetINIInteger mMGInputFilename "maxMazeGenerator" "mMGSeedValue" 42
		mMGBraidValue = sLibGetINIFloat mMGInputFilename "maxMazeGenerator" "mMGBraidValue" 0.0
		mMGDepthValue = sLibGetINIFloat mMGInputFilename "maxMazeGenerator" "mMGDepthValue" 2.0
		mMGWallWidthValue = sLibGetINIFloat mMGInputFilename "maxMazeGenerator" "mMGWallWidthValue" 0.3
		mMGAutoConvertValue = sLibGetINIBoolean mMGInputFilename "maxMazeGenerator" "mMGAutoConvertValue" true
		mMGPosValue = sLibGetINIPoint2 mMGInputFilename "maxMazeGenerator" "mMGPosValue" (sLibGetSafeUIPos 280 300)
		)
	)

fn mMGSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	mMGOutputFilename = presetDir + "maxMazeGenerator.ini"
	if (sLibFileExist mMGOutputFilename == true) then deleteFile mMGOutputFilename
	setINISetting mMGOutputFilename "maxMazeGenerator" "mMGSeedValue" (mMGSeedValue as string)
	setINISetting mMGOutputFilename "maxMazeGenerator" "mMGBraidValue" (mMGBraidValue as string)
	setINISetting mMGOutputFilename "maxMazeGenerator" "mMGDepthValue" (mMGDepthValue as string)
	setINISetting mMGOutputFilename "maxMazeGenerator" "mMGWallWidthValue" (mMGWallWidthValue as string)
	setINISetting mMGOutputFilename "maxMazeGenerator" "mMGAutoConvertValue" (mMGAutoConvertValue as string)
	setINISetting mMGOutputFilename "maxMazeGenerator" "mMGPosValue" (mMGFloater.pos as string)
	)

-- UI

fn mMGDefineUI =
	(
	rollout mMGRollout "maxMazeGenerator"
		(
		spinner mMGSeedSpinner "Seed: " range:[-99999,99999,42] type:#integer fieldWidth:60 align:#right
		spinner mMGBraidSpinner "Braid / Loops: " range:[0.0,1.0,0.0] type:#float scale:0.01 fieldWidth:60 align:#right
		spinner mMGDepthSpinner "Wall Height (units): " range:[0.0,1000.0,2.0] type:#float scale:0.1 fieldWidth:60 align:#right
		spinner mMGWallWidthSpinner "Wall Inset Fraction: " range:[0.0,0.5,0.3] type:#float scale:0.01 fieldWidth:60 align:#right

		label mMGSpacer1 "" height:4
		checkbox mMGAutoConvertCheckbox "Auto-convert to Editable Poly" checked:true align:#left

		label mMGSpacer2 "" height:4
		button mMGGenerateButton "Generate Maze On Selection" width:250 height:28 align:#center
		button mMGFlattenButton "Flatten (Remove Walls)" width:250 height:22 align:#center

		label mMGSpacer3 "" height:4
		label mMGStatusLabel "Ready." align:#left

		button mMGHelpButton "Help" width:80 align:#left across:2
		button mMGSaveDefButton "SaveDef" width:80 align:#right

		-- Handlers
		on mMGSeedSpinner changed val do mMGSeedValue = val
		on mMGBraidSpinner changed val do mMGBraidValue = val
		on mMGDepthSpinner changed val do mMGDepthValue = val
		on mMGWallWidthSpinner changed val do mMGWallWidthValue = val
		on mMGAutoConvertCheckbox changed state do mMGAutoConvertValue = state

		on mMGGenerateButton pressed do
			(
			mMGStatusLabel.text = "Running..."
			mMGGenerate mMGSeedValue mMGBraidValue mMGDepthValue mMGWallWidthValue mMGAutoConvertValue
			mMGStatusLabel.text = mMGLastResult
			)

		on mMGFlattenButton pressed do
			(
			mMGStatusLabel.text = "Running..."
			mMGFlatten mMGAutoConvertValue
			mMGStatusLabel.text = mMGLastResult
			)

		on mMGHelpButton pressed do mMGHelp()
		on mMGSaveDefButton pressed do mMGSaveDef()

		on mMGRollout open do
			(
			mMGSeedSpinner.value = mMGSeedValue
			mMGBraidSpinner.value = mMGBraidValue
			mMGDepthSpinner.value = mMGDepthValue
			mMGWallWidthSpinner.value = mMGWallWidthValue
			mMGAutoConvertCheckbox.checked = mMGAutoConvertValue
			mMGStatusLabel.text = mMGLastResult
			)
		)
	)
)
-------------------------------------------------------------------------------
