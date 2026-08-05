-------------------------------------------------------------------------------
-- physicalCameraManager.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Batch control Physical Camera exposure (EV), ISO, f-stop, shutter speed,
-- focal length, and White Balance across all Physical Cameras in the scene
-- or just the selected ones.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global physicalCameraManager
global physicalCameraManagerDefaults
global physicalCameraManagerUI

global pCMCloseOpenUI
global pCMDo
global pCMApply
global pCMHelp
global pCMLoadDef
global pCMSaveDef
global pCMDefineUI
global pCMRollout
global pCMFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
pCMTargetValue = 1  -- 1=All Scene Cams, 2=Selected Only
pCMSetISOValue = false
pCMISOValue = 100.0
pCMSetApertureValue = false
pCMApertureValue = 8.0
pCMSetShutterValue = false
pCMShutterValue = 0.0083333  -- 1/120
pCMSetFocalLengthValue = false
pCMFocalLengthValue = 50.0
pCMSetWhiteBalanceValue = false
pCMWhiteBalanceValue = 6500
pCMPosValue = sLibGetSafeUIPos 310 360

-- Functions

fn physicalCameraManager pCMTarget pCMSetISO pCMISO pCMSetAperture pCMAperture pCMSetShutter pCMShutter pCMSetFocalLength pCMFocalLength pCMSetWB pCMWB =
	(
	local cams = #()
	if pCMTarget == 1 then
		(
		-- All Physical Cameras in scene
		for c in cameras do
			(
			try (if (classof c) == Physical_Camera then append cams c) catch ()
			)
		)
	else
		(
		for c in selection do
			(
			try (if (classof c) == Physical_Camera then append cams c) catch ()
			)
		)
	if cams.count == 0 then (MessageBox "No Physical Cameras found." title:"physicalCameraManager")
	else
		(
		for c in cams do
			(
			try
				(
				if pCMSetISO then setProperty c "iso" pCMISO
				if pCMSetAperture then setProperty c "aperture" pCMAperture
				if pCMSetShutter then setProperty c "shutter_value" pCMShutter
				if pCMSetFocalLength then setProperty c "focal_length" pCMFocalLength
				if pCMSetWB then setProperty c "white_balance" (color pCMWB pCMWB pCMWB)
				) catch ()
			)
		MessageBox (cams.count as string + " Physical Camera(s) updated.") title:"physicalCameraManager"
		)
	)

fn physicalCameraManagerDefaults =
	(
	pCMLoadDef()
	physicalCameraManager pCMTargetValue pCMSetISOValue pCMISOValue pCMSetApertureValue pCMApertureValue pCMSetShutterValue pCMShutterValue pCMSetFocalLengthValue pCMFocalLengthValue pCMSetWhiteBalanceValue pCMWhiteBalanceValue
	)

fn physicalCameraManagerUI =
	(
	pCMLoadDef()
	pCMCloseOpenUI pCMPosValue
	)

fn pCMCloseOpenUI pos =
	(
	if pCMFloater != undefined then CloseRolloutFloater pCMFloater
	pCMDefineUI()
	pCMFloater = newRolloutFloater "physicalCameraManager v1.00" 310 360 pos.x pos.y
	addRollout pCMRollout pCMFloater
	)

fn pCMHelp =
	(
	MessageBox "physicalCameraManager: Batch-modify Physical Camera properties.\nChoose target, check values to set, then hit Do." title:"physicalCameraManager Help"
	)

fn pCMLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	pCMInputFilename = presetDir + "physicalCameraManager.ini"
	if (sLibFileExist pCMInputFilename == true) then
		(
		pCMTargetValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMTargetValue") as integer
		pCMSetISOValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMSetISOValue") == "true"
		pCMISOValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMISOValue") as float
		pCMSetApertureValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMSetApertureValue") == "true"
		pCMApertureValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMApertureValue") as float
		pCMSetShutterValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMSetShutterValue") == "true"
		pCMShutterValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMShutterValue") as float
		pCMSetFocalLengthValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMSetFocalLengthValue") == "true"
		pCMFocalLengthValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMFocalLengthValue") as float
		pCMSetWhiteBalanceValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMSetWhiteBalanceValue") == "true"
		pCMWhiteBalanceValue = (getINISetting pCMInputFilename "physicalCameraManager" "pCMWhiteBalanceValue") as integer
		pCMPosValue = sLibGetINIPoint2 pCMInputFilename "physicalCameraManager" "pCMPosValue" (sLibGetSafeUIPos 310 360)
		if pCMTargetValue == 0 then pCMTargetValue = 1
		if pCMISOValue == 0.0 then pCMISOValue = 100.0
		if pCMApertureValue == 0.0 then pCMApertureValue = 8.0
		if pCMShutterValue == 0.0 then pCMShutterValue = 0.0083333
		if pCMFocalLengthValue == 0.0 then pCMFocalLengthValue = 50.0
		if pCMWhiteBalanceValue == 0 then pCMWhiteBalanceValue = 6500
		)
	else
		(
		pCMTargetValue = 1; pCMSetISOValue = false; pCMISOValue = 100.0
		pCMSetApertureValue = false; pCMApertureValue = 8.0
		pCMSetShutterValue = false; pCMShutterValue = 0.0083333
		pCMSetFocalLengthValue = false; pCMFocalLengthValue = 50.0
		pCMSetWhiteBalanceValue = false; pCMWhiteBalanceValue = 6500
		pCMPosValue = sLibGetSafeUIPos 310 360
		)
	)

fn pCMSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	pCMOutputFilename = presetDir + "physicalCameraManager.ini"
	if (sLibFileExist pCMOutputFilename == true) then deleteFile pCMOutputFilename
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMTargetValue" (pCMTargetValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMSetISOValue" (pCMSetISOValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMISOValue" (pCMISOValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMSetApertureValue" (pCMSetApertureValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMApertureValue" (pCMApertureValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMSetShutterValue" (pCMSetShutterValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMShutterValue" (pCMShutterValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMSetFocalLengthValue" (pCMSetFocalLengthValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMFocalLengthValue" (pCMFocalLengthValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMSetWhiteBalanceValue" (pCMSetWhiteBalanceValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMWhiteBalanceValue" (pCMWhiteBalanceValue as string)
	setINISetting pCMOutputFilename "physicalCameraManager" "pCMPosValue" (pCMFloater.pos as string)
	)

-- UI

fn pCMDefineUI =
	(
	rollout pCMRollout "physicalCameraManager"
		(
		group "Target"
			(
			dropdownlist pCMTargetDropdown "" items:#("All Scene Physical Cameras","Selected Physical Cameras Only") selection:pCMTargetValue width:260 align:#center
			)
		group "Exposure"
			(
			checkbox pCMSetISOCheckbox "Set ISO" checked:pCMSetISOValue align:#left
			spinner pCMISOSpinner "ISO: " range:[1,999999,pCMISOValue] fieldWidth:70 type:#float align:#right
			checkbox pCMSetApertureCheckbox "Set f-stop (Aperture)" checked:pCMSetApertureValue align:#left
			spinner pCMApertureSpinner "f-stop: " range:[0.5,128.0,pCMApertureValue] fieldWidth:70 type:#float align:#right
			checkbox pCMSetShutterCheckbox "Set Shutter Speed (sec)" checked:pCMSetShutterValue align:#left
			spinner pCMShutterSpinner "Shutter (s): " range:[0.00001,10.0,pCMShutterValue] fieldWidth:70 type:#float align:#right
			)
		group "Optics"
			(
			checkbox pCMSetFocalLengthCheckbox "Set Focal Length (mm)" checked:pCMSetFocalLengthValue align:#left
			spinner pCMFocalLengthSpinner "Focal (mm): " range:[1.0,10000.0,pCMFocalLengthValue] fieldWidth:70 type:#float align:#right
			checkbox pCMSetWhiteBalanceCheckbox "Set White Balance (K)" checked:pCMSetWhiteBalanceValue align:#left
			spinner pCMWhiteBalanceSpinner "WB (K): " range:[1000,20000,pCMWhiteBalanceValue] fieldWidth:70 type:#integer align:#right
			)

		on pCMTargetDropdown selected i do pCMTargetValue = i
		on pCMSetISOCheckbox changed s do pCMSetISOValue = s
		on pCMISOSpinner changed v do pCMISOValue = v
		on pCMSetApertureCheckbox changed s do pCMSetApertureValue = s
		on pCMApertureSpinner changed v do pCMApertureValue = v
		on pCMSetShutterCheckbox changed s do pCMSetShutterValue = s
		on pCMShutterSpinner changed v do pCMShutterValue = v
		on pCMSetFocalLengthCheckbox changed s do pCMSetFocalLengthValue = s
		on pCMFocalLengthSpinner changed v do pCMFocalLengthValue = v
		on pCMSetWhiteBalanceCheckbox changed s do pCMSetWhiteBalanceValue = s
		on pCMWhiteBalanceSpinner changed v do pCMWhiteBalanceValue = v

		button pCMDoButton "Do" width:80 align:#left across:3
		button pCMApplyButton "Apply" width:80 align:#center
		button pCMHelpButton "Help" width:50 align:#right
		on pCMDoButton pressed do
			(
			physicalCameraManager pCMTargetValue pCMSetISOValue pCMISOValue pCMSetApertureValue pCMApertureValue pCMSetShutterValue pCMShutterValue pCMSetFocalLengthValue pCMFocalLengthValue pCMSetWhiteBalanceValue pCMWhiteBalanceValue
			if pCMFloater != undefined then CloseRolloutFloater pCMFloater
			)
		on pCMApplyButton pressed do
			physicalCameraManager pCMTargetValue pCMSetISOValue pCMISOValue pCMSetApertureValue pCMApertureValue pCMSetShutterValue pCMShutterValue pCMSetFocalLengthValue pCMFocalLengthValue pCMSetWhiteBalanceValue pCMWhiteBalanceValue
		on pCMHelpButton pressed do pCMHelp()
		button pCMSaveDefButton "SaveDef" width:80 align:#center
		on pCMSaveDefButton pressed do pCMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------
