-------------------------------------------------------------------------------
-- cinematicCameraMaker.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-- scripts/SoulburnScripts/lib/cinecam.py
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Interactive UI for creating cinematic camera moves on a Physical Camera.
-- Uses cinecam.py (pure Python, no DCC imports) to generate keyframe arrays,
-- then writes pos/target/FOV keys to the selected camera.
-- 10 move types: Arc, Dolly, Truck, Pedestal, Tracking, Pass-Through,
-- Helix, Whip Pan, Handheld, Dolly Zoom.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global cinematicCameraMakerDefaults
global cinematicCameraMakerUI

global cCMCloseOpenUI
global cCMExecuteMove
global cCMHelp
global cCMLoadDef
global cCMSaveDef
global cCMDefineUI
global cCMRollout
global cCMFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
cCMMoveTypeValue = 1  -- 1=arc, 2=dolly, 3=truck, 4=pedestal, 5=tracking, 6=pass_through, 7=helix, 8=whip_pan, 9=handheld, 10=dolly_zoom
cCMStartFrameValue = 0
cCMEndFrameValue = 100
cCMRadiusValue = 200.0
cCMHeightValue = 100.0
cCMBearingValue = 0.0
cCMSweepValue = 90.0
cCMSpeedValue = 1.0
cCMClampAboveValue = false
cCMFOVValue = 60.0
cCMPosValue = sLibGetSafeUIPos 340 390

global cCMSubjectNode = undefined
global cCMCameraNode = undefined

-- Functions

fn cCMWriteKeysToCamera cam keyframes =
	(
	-- Write pos/target/fov keys from Python keyframe array to selected camera
	-- keyframes is an array of structs with .frame, .pos, .target, .fov
	if cam == undefined then return false
	local wasAnimating = animationRange
	with animate on
		(
		for kf in keyframes do
			(
			at time kf.frame
				(
				try
					(
					cam.pos = kf.cpos
					if cam.target != undefined then cam.target.pos = kf.ctarget
					setProperty cam "fov" kf.cfov
					) catch ()
				)
			)
		)
	return true
	)

fn cCMRunPythonCineMove moveType startFrame endFrame radius height bearing sweep speed clampAbove fov =
	(
	-- Execute cinecam.py via Max's embedded Python and return keyframe data
	-- cinecam.py must be in $scripts\SoulburnScripts\lib\
	local pyLibPath = ((getdir #userScripts) + "\\SoulburnScripts\\lib\\cinecam.py")
	if not (doesFileExist pyLibPath) then
		(
		MessageBox "cinecam.py not found at:\n" + pyLibPath + "\n\nPlease reinstall SoulBurn Scripts." title:"cinematicCameraMaker"
		return undefined
		)
	local moveNames = #("arc","dolly","truck","pedestal","tracking","pass_through","helix","whip_pan","handheld","dolly_zoom")
	local moveName = moveNames[moveType]

	-- Write a temp Python script to disk to avoid string escaping issues
	local tempDir = (getdir #temp)
	local tempPy = (tempDir + "\\sb_cinecam_run.py")
	local tempJson = (tempDir + "\\sb_cinecam_result.json")
	local pyCode = "import sys, json\n"
	pyCode += "sys.path.insert(0, r'" + (substituteString pyLibPath "\\" "\\\\") + "'.rsplit('\\\\',1)[0])\n"
	pyCode += "from cinecam import " + moveName + "\n"
	pyCode += "keys = " + moveName + "(\n"
	pyCode += "    start_frame=" + (startFrame as string) + ",\n"
	pyCode += "    end_frame=" + (endFrame as string) + ",\n"
	pyCode += "    radius=" + (radius as string) + ".0,\n"
	pyCode += "    height=" + (height as string) + ".0,\n"
	pyCode += "    bearing_deg=" + (bearing as string) + ".0,\n"
	pyCode += "    sweep_deg=" + (sweep as string) + ".0,\n"
	pyCode += "    speed=" + (speed as string) + ".0,\n"
	pyCode += "    clamp_above=" + (if clampAbove then "True" else "False") + ",\n"
	pyCode += "    fov=" + (fov as string) + ".0\n"
	pyCode += ")\n"
	pyCode += "with open(r'" + (substituteString tempJson "\\" "\\\\") + "', 'w') as f:\n"
	pyCode += "    json.dump(keys, f)\n"

	local pyFile = createFile tempPy
	format pyCode to:pyFile
	close pyFile

	-- Run via python.ExecuteFile
	try (python.ExecuteFile tempPy)
	catch (MessageBox "Python execution failed. Check Max's embedded Python." title:"cinematicCameraMaker"; return undefined)

	-- Read back JSON
	if not (doesFileExist tempJson) then
		(
		MessageBox "cinecam.py did not produce output. Check Max's Script Editor output for errors." title:"cinematicCameraMaker"
		return undefined
		)
	local jsonFile = openFile tempJson
	local jsonStr = ""
	while not eof jsonFile do jsonStr += (readLine jsonFile) + "\n"
	close jsonFile
	deleteFile tempJson

	-- Parse JSON array of {frame, pos, target, fov} into MaxScript structs
	struct _CineKey (frame, cpos, ctarget, cfov)
	local result = #()
	-- Simple regex-free parse: split on "}," then extract fields
	local entries = filterString jsonStr "},"
	for e in entries do
		(
		try
			(
			-- Extract frame
			local fStart = (findString e "\"frame\": ") + 9
			local fEnd = (findString e ",") - 1
			local frameVal = (substring e fStart (fEnd - fStart + 1)) as integer
			-- Extract pos
			local pStr = (findString e "\"pos\": [")
			local pEnd = (findString e "]," pattern:(pStr + 10))
			local posStr = substring e (pStr+9) (pEnd - pStr - 9)
			local posArr = filterString posStr ","
			local posVec = [(posArr[1] as float), (posArr[2] as float), (posArr[3] as float)]
			-- Extract target
			local tStr = (findString e "\"target\": [")
			local tEnd = (findString e "]," pattern:(tStr + 11))
			local targStr = substring e (tStr+12) (tEnd - tStr - 12)
			local targArr = filterString targStr ","
			local targVec = [(targArr[1] as float), (targArr[2] as float), (targArr[3] as float)]
			-- Extract fov
			local fovStr = (findString e "\"fov\": ")
			local fovVal = (substring e (fovStr+7) 8) as float
			append result (_CineKey frame:frameVal cpos:posVec ctarget:targVec cfov:fovVal)
			) catch ()
		)
	return result
	)

fn cCMExecuteMove =
	(
	if cCMCameraNode == undefined then
		(
		MessageBox "Please pick a Physical Camera first." title:"cinematicCameraMaker"
		return false
		)
	local keys = cCMRunPythonCineMove cCMMoveTypeValue cCMStartFrameValue cCMEndFrameValue cCMRadiusValue cCMHeightValue cCMBearingValue cCMSweepValue cCMSpeedValue cCMClampAboveValue cCMFOVValue
	if keys == undefined then return false
	if keys.count == 0 then (MessageBox "No keyframes returned from cinecam.py." title:"cinematicCameraMaker"; return false)
	cCMWriteKeysToCamera cCMCameraNode keys
	MessageBox (keys.count as string + " keyframes written to: " + cCMCameraNode.name) title:"cinematicCameraMaker"
	return true
	)

fn cinematicCameraMakerDefaults =
	(
	cCMLoadDef()
	cCMExecuteMove()
	)

fn cinematicCameraMakerUI =
	(
	cCMLoadDef()
	cCMCloseOpenUI cCMPosValue
	)

fn cCMCloseOpenUI pos =
	(
	if cCMFloater != undefined then CloseRolloutFloater cCMFloater
	cCMDefineUI()
	cCMFloater = newRolloutFloater "cinematicCameraMaker v1.00" 340 390 pos.x pos.y
	addRollout cCMRollout cCMFloater
	)

fn cCMHelp =
	(
	MessageBox "cinematicCameraMaker: Generate cinematic camera moves using cinecam.py.\n\n1. Pick a Physical Camera (or Target Camera).\n2. Set optional Subject node.\n3. Choose move type and parameters.\n4. Click Execute Move." title:"cinematicCameraMaker Help"
	)

fn cCMLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cCMInputFilename = presetDir + "cinematicCameraMaker.ini"
	if (sLibFileExist cCMInputFilename == true) then
		(
		cCMMoveTypeValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMMoveTypeValue") as integer
		cCMStartFrameValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMStartFrameValue") as integer
		cCMEndFrameValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMEndFrameValue") as integer
		cCMRadiusValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMRadiusValue") as float
		cCMHeightValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMHeightValue") as float
		cCMBearingValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMBearingValue") as float
		cCMSweepValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMSweepValue") as float
		cCMSpeedValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMSpeedValue") as float
		cCMClampAboveValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMClampAboveValue") == "true"
		cCMFOVValue = (getINISetting cCMInputFilename "cinematicCameraMaker" "cCMFOVValue") as float
		cCMPosValue = sLibGetINIPoint2 cCMInputFilename "cinematicCameraMaker" "cCMPosValue" (sLibGetSafeUIPos 340 390)
		if cCMMoveTypeValue == 0 then cCMMoveTypeValue = 1
		if cCMEndFrameValue == 0 then cCMEndFrameValue = 100
		if cCMRadiusValue == 0.0 then cCMRadiusValue = 200.0
		if cCMHeightValue == 0.0 then cCMHeightValue = 100.0
		if cCMSweepValue == 0.0 then cCMSweepValue = 90.0
		if cCMSpeedValue == 0.0 then cCMSpeedValue = 1.0
		if cCMFOVValue == 0.0 then cCMFOVValue = 60.0
		)
	else
		(
		cCMMoveTypeValue = 1; cCMStartFrameValue = 0; cCMEndFrameValue = 100
		cCMRadiusValue = 200.0; cCMHeightValue = 100.0; cCMBearingValue = 0.0
		cCMSweepValue = 90.0; cCMSpeedValue = 1.0; cCMClampAboveValue = false
		cCMFOVValue = 60.0; cCMPosValue = sLibGetSafeUIPos 340 390
		)
	)

fn cCMSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cCMOutputFilename = presetDir + "cinematicCameraMaker.ini"
	if (sLibFileExist cCMOutputFilename == true) then deleteFile cCMOutputFilename
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMMoveTypeValue" (cCMMoveTypeValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMStartFrameValue" (cCMStartFrameValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMEndFrameValue" (cCMEndFrameValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMRadiusValue" (cCMRadiusValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMHeightValue" (cCMHeightValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMBearingValue" (cCMBearingValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMSweepValue" (cCMSweepValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMSpeedValue" (cCMSpeedValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMClampAboveValue" (cCMClampAboveValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMFOVValue" (cCMFOVValue as string)
	setINISetting cCMOutputFilename "cinematicCameraMaker" "cCMPosValue" (cCMFloater.pos as string)
	)

-- UI

fn cCMDefineUI =
	(
	rollout cCMRollout "cinematicCameraMaker"
		(
		group "Camera & Subject"
			(
			pickbutton cCMPickCamButton "Pick Camera" width:140 align:#left message:"Pick Physical Camera or Target Camera"
			pickbutton cCMPickSubjectButton "Pick Subject (opt)" width:140 align:#left message:"Pick subject object for Tracking moves"
			label cCMCamLabel "Camera: (none)" width:280 align:#left
			label cCMSubjectLabel "Subject: (none)" width:280 align:#left
			)
		group "Move Parameters"
			(
			dropdownlist cCMMoveTypeDropdown "Move: " items:#("Arc","Dolly","Truck","Pedestal","Tracking","Pass-Through","Helix","Whip Pan","Handheld","Dolly Zoom") selection:cCMMoveTypeValue width:160 align:#right
			spinner cCMStartFrameSpinner "Start Frame: " range:[0,99999,cCMStartFrameValue] fieldWidth:50 type:#integer align:#right
			spinner cCMEndFrameSpinner "End Frame: " range:[0,99999,cCMEndFrameValue] fieldWidth:50 type:#integer align:#right
			spinner cCMRadiusSpinner "Radius: " range:[0.01,999999,cCMRadiusValue] fieldWidth:70 type:#float align:#right
			spinner cCMHeightSpinner "Height: " range:[-999999,999999,cCMHeightValue] fieldWidth:70 type:#float align:#right
			spinner cCMBearingSpinner "Bearing (deg): " range:[-360,360,cCMBearingValue] fieldWidth:60 type:#float align:#right
			spinner cCMSweepSpinner "Sweep (deg): " range:[0,720,cCMSweepValue] fieldWidth:60 type:#float align:#right
			spinner cCMSpeedSpinner "Speed: " range:[0.01,100,cCMSpeedValue] fieldWidth:60 type:#float align:#right
			spinner cCMFOVSpinner "FOV (deg): " range:[1,179,cCMFOVValue] fieldWidth:60 type:#float align:#right
			checkbox cCMClampAboveCheckbox "Clamp Above (terrain guard)" checked:cCMClampAboveValue align:#left
			)

		on cCMPickCamButton picked node do
			(
			cCMCameraNode = node
			cCMCamLabel.text = "Camera: " + node.name
			)
		on cCMPickSubjectButton picked node do
			(
			cCMSubjectNode = node
			cCMSubjectLabel.text = "Subject: " + node.name
			)
		on cCMMoveTypeDropdown selected i do cCMMoveTypeValue = i
		on cCMStartFrameSpinner changed v do cCMStartFrameValue = v
		on cCMEndFrameSpinner changed v do cCMEndFrameValue = v
		on cCMRadiusSpinner changed v do cCMRadiusValue = v
		on cCMHeightSpinner changed v do cCMHeightValue = v
		on cCMBearingSpinner changed v do cCMBearingValue = v
		on cCMSweepSpinner changed v do cCMSweepValue = v
		on cCMSpeedSpinner changed v do cCMSpeedValue = v
		on cCMFOVSpinner changed v do cCMFOVValue = v
		on cCMClampAboveCheckbox changed s do cCMClampAboveValue = s

		button cCMExecuteButton "Execute Move" width:160 align:#left across:2
		button cCMHelpButton "Help" width:80 align:#right
		on cCMExecuteButton pressed do cCMExecuteMove()
		on cCMHelpButton pressed do cCMHelp()
		button cCMSaveDefButton "SaveDef" width:80 align:#center
		on cCMSaveDefButton pressed do cCMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------
