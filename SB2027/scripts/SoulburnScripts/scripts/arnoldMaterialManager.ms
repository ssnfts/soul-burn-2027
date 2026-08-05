-------------------------------------------------------------------------------
-- arnoldMaterialManager.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027 + Arnold 7
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Batch-manage Arnold Standard Surface material properties across selected
-- objects. Toggle subdivision, displacement, opacity, and visibility flags
-- on all Arnold materials in one click.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select objects with Arnold Standard Surface materials. Run the UI version.
-- Check/uncheck the properties you want to change. Hit Do.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global arnoldMaterialManager
global arnoldMaterialManagerDefaults
global arnoldMaterialManagerUI

global aMCloseOpenUI
global aMDo
global aMApply
global aMHelp
global aMLoadDef
global aMSaveDef
global aMDefineUI
global aMRollout
global aMFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
aMSubdivEnableValue = false
aMSubdivIterValue = 2
aMSubdivTypeValue = 1  -- 1=catclark, 2=linear
aMDispEnableValue = false
aMDispHeightValue = 1.0
aMOpacityValue = 1.0
aMSetOpacityValue = false
aMCastShadowsValue = true
aMSetCastShadowsValue = false
aMSelfShadowsValue = true
aMSetSelfShadowsValue = false
aMPosValue = sLibGetSafeUIPos 300 370

-- Functions

fn arnoldMaterialManager aMSubdivEnable aMSubdivIter aMSubdivType aMDispEnable aMDispHeight aMSetOpacity aMOpacity aMSetCastShadows aMCastShadows aMSetSelfShadows aMSelfShadows =
	(
	if $ == undefined then (MessageBox "Please select at least one object." title:"arnoldMaterialManager")
	else
		(
		local mats = sLibGetAllMaterialsOnSelectedObjects()
		local arnMats = #()
		for m in mats do
			(
			try (if (classof m) == Arnold_Standard_Surface then append arnMats m) catch ()
			)
		if arnMats.count == 0 then (MessageBox "No Arnold Standard Surface materials found on selected objects." title:"arnoldMaterialManager")
		else
			(
			for m in arnMats do
				(
				try
					(
					if aMSubdivEnable then
						(
						setProperty m "subdiv_type" (aMSubdivType - 1)
						setProperty m "subdiv_iterations" aMSubdivIter
						)
					if aMDispEnable then
						(
						setProperty m "disp_height" aMDispHeight
						)
					if aMSetOpacity then
						(
						setProperty m "opacity" (color (aMOpacity*255) (aMOpacity*255) (aMOpacity*255))
						)
					if aMSetCastShadows then
						(
						setProperty m "cast_shadows" aMCastShadows
						)
					if aMSetSelfShadows then
						(
						setProperty m "self_shadows" aMSelfShadows
						)
					) catch ()
				)
			MessageBox (arnMats.count as string + " Arnold material(s) updated.") title:"arnoldMaterialManager"
			)
		)
	)

fn arnoldMaterialManagerDefaults =
	(
	aMLoadDef()
	arnoldMaterialManager aMSubdivEnableValue aMSubdivIterValue aMSubdivTypeValue aMDispEnableValue aMDispHeightValue aMSetOpacityValue aMOpacityValue aMSetCastShadowsValue aMCastShadowsValue aMSetSelfShadowsValue aMSelfShadowsValue
	)

fn arnoldMaterialManagerUI =
	(
	aMLoadDef()
	aMCloseOpenUI aMPosValue
	)

fn aMCloseOpenUI pos =
	(
	if aMFloater != undefined then CloseRolloutFloater aMFloater
	aMDefineUI()
	aMFloater = newRolloutFloater "arnoldMaterialManager v1.00" 300 370 pos.x pos.y
	addRollout aMRollout aMFloater
	)

fn aMHelp =
	(
	MessageBox "arnoldMaterialManager: Batch-modify Arnold Standard Surface properties on selected objects.\nSelect objects, set desired values, hit Do." title:"arnoldMaterialManager Help"
	)

fn aMLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	aMInputFilename = presetDir + "arnoldMaterialManager.ini"
	if (sLibFileExist aMInputFilename == true) then
		(
		aMSubdivEnableValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMSubdivEnableValue") == "true"
		aMSubdivIterValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMSubdivIterValue") as integer
		aMSubdivTypeValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMSubdivTypeValue") as integer
		aMDispEnableValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMDispEnableValue") == "true"
		aMDispHeightValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMDispHeightValue") as float
		aMSetOpacityValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMSetOpacityValue") == "true"
		aMOpacityValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMOpacityValue") as float
		aMSetCastShadowsValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMSetCastShadowsValue") == "true"
		aMCastShadowsValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMCastShadowsValue") == "true"
		aMSetSelfShadowsValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMSetSelfShadowsValue") == "true"
		aMSelfShadowsValue = (getINISetting aMInputFilename "arnoldMaterialManager" "aMSelfShadowsValue") == "true"
		aMPosValue = sLibGetINIPoint2 aMInputFilename "arnoldMaterialManager" "aMPosValue" (sLibGetSafeUIPos 300 370)
		if aMSubdivIterValue == 0 then aMSubdivIterValue = 2
		if aMSubdivTypeValue == 0 then aMSubdivTypeValue = 1
		if aMDispHeightValue == 0.0 then aMDispHeightValue = 1.0
		if aMOpacityValue == 0.0 then aMOpacityValue = 1.0
		)
	else
		(
		aMSubdivEnableValue = false
		aMSubdivIterValue = 2
		aMSubdivTypeValue = 1
		aMDispEnableValue = false
		aMDispHeightValue = 1.0
		aMSetOpacityValue = false
		aMOpacityValue = 1.0
		aMSetCastShadowsValue = false
		aMCastShadowsValue = true
		aMSetSelfShadowsValue = false
		aMSelfShadowsValue = true
		aMPosValue = sLibGetSafeUIPos 300 370
		)
	)

fn aMSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	aMOutputFilename = presetDir + "arnoldMaterialManager.ini"
	if (sLibFileExist aMOutputFilename == true) then deleteFile aMOutputFilename
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMSubdivEnableValue" (aMSubdivEnableValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMSubdivIterValue" (aMSubdivIterValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMSubdivTypeValue" (aMSubdivTypeValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMDispEnableValue" (aMDispEnableValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMDispHeightValue" (aMDispHeightValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMSetOpacityValue" (aMSetOpacityValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMOpacityValue" (aMOpacityValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMSetCastShadowsValue" (aMSetCastShadowsValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMCastShadowsValue" (aMCastShadowsValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMSetSelfShadowsValue" (aMSetSelfShadowsValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMSelfShadowsValue" (aMSelfShadowsValue as string)
	setINISetting aMOutputFilename "arnoldMaterialManager" "aMPosValue" (aMFloater.pos as string)
	)

-- UI

fn aMDefineUI =
	(
	rollout aMRollout "arnoldMaterialManager"
		(
		group "Subdivision"
			(
			checkbox aMSubdivEnableCheckbox "Set Subdivision" checked:aMSubdivEnableValue align:#left
			spinner aMSubdivIterSpinner "Iterations: " range:[0,20,aMSubdivIterValue] fieldWidth:40 type:#integer align:#right
			dropdownlist aMSubdivTypeDropdown "Type: " items:#("catclark","linear") selection:aMSubdivTypeValue width:100 align:#right
			)
		group "Displacement"
			(
			checkbox aMDispEnableCheckbox "Set Displacement Height" checked:aMDispEnableValue align:#left
			spinner aMDispHeightSpinner "Height: " range:[0,99999,aMDispHeightValue] fieldWidth:60 type:#float align:#right
			)
		group "Opacity"
			(
			checkbox aMSetOpacityCheckbox "Set Opacity" checked:aMSetOpacityValue align:#left
			spinner aMOpacitySpinner "Opacity: " range:[0.0,1.0,aMOpacityValue] fieldWidth:60 type:#float align:#right
			)
		group "Visibility"
			(
			checkbox aMSetCastShadowsCheckbox "Set Cast Shadows" checked:aMSetCastShadowsValue align:#left
			checkbox aMCastShadowsCheckbox "  Cast Shadows" checked:aMCastShadowsValue align:#left
			checkbox aMSetSelfShadowsCheckbox "Set Self Shadows" checked:aMSetSelfShadowsValue align:#left
			checkbox aMSelfShadowsCheckbox "  Self Shadows" checked:aMSelfShadowsValue align:#left
			)

		on aMSubdivEnableCheckbox changed s do aMSubdivEnableValue = s
		on aMSubdivIterSpinner changed v do aMSubdivIterValue = v
		on aMSubdivTypeDropdown selected i do aMSubdivTypeValue = i
		on aMDispEnableCheckbox changed s do aMDispEnableValue = s
		on aMDispHeightSpinner changed v do aMDispHeightValue = v
		on aMSetOpacityCheckbox changed s do aMSetOpacityValue = s
		on aMOpacitySpinner changed v do aMOpacityValue = v
		on aMSetCastShadowsCheckbox changed s do aMSetCastShadowsValue = s
		on aMCastShadowsCheckbox changed s do aMCastShadowsValue = s
		on aMSetSelfShadowsCheckbox changed s do aMSetSelfShadowsValue = s
		on aMSelfShadowsCheckbox changed s do aMSelfShadowsValue = s

		button aMDoButton "Do" width:80 align:#left across:3
		button aMApplyButton "Apply" width:80 align:#center
		button aMHelpButton "Help" width:50 align:#right

		on aMDoButton pressed do
			(
			arnoldMaterialManager aMSubdivEnableValue aMSubdivIterValue aMSubdivTypeValue aMDispEnableValue aMDispHeightValue aMSetOpacityValue aMOpacityValue aMSetCastShadowsValue aMCastShadowsValue aMSetSelfShadowsValue aMSelfShadowsValue
			if aMFloater != undefined then CloseRolloutFloater aMFloater
			)
		on aMApplyButton pressed do
			arnoldMaterialManager aMSubdivEnableValue aMSubdivIterValue aMSubdivTypeValue aMDispEnableValue aMDispHeightValue aMSetOpacityValue aMOpacityValue aMSetCastShadowsValue aMCastShadowsValue aMSetSelfShadowsValue aMSelfShadowsValue
		on aMHelpButton pressed do aMHelp()

		button aMSaveDefButton "SaveDef" width:80 align:#center
		on aMSaveDefButton pressed do aMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------
