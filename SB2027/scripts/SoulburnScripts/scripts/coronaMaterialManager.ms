-------------------------------------------------------------------------------
-- coronaMaterialManager.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027 + Corona 11
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Batch-manage Corona Material properties across selected objects.
-- Toggle displacement, scatter density, and render override flags.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global coronaMaterialManager
global coronaMaterialManagerDefaults
global coronaMaterialManagerUI

global cMMCloseOpenUI
global cMMDo
global cMMApply
global cMMHelp
global cMMLoadDef
global cMMSaveDef
global cMMDefineUI
global cMMRollout
global cMMFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
cMMSetDispValue = false
cMMDispAmountValue = 1.0
cMMDispOffsetValue = 0.0
cMMSetGlossValue = false
cMMGlossValue = 1.0
cMMSetReflGlossValue = false
cMMReflGlossValue = 1.0
cMMSetOpacityValue = false
cMMOpacityValue = 1.0
cMMExcludeFromGIValue = false
cMMSetExcludeGIValue = false
cMMPosValue = sLibGetSafeUIPos 310 330

-- Functions

fn coronaMaterialManager cMMSetDisp cMMDispAmount cMMDispOffset cMMSetGloss cMMGloss cMMSetReflGloss cMMReflGloss cMMSetOpacity cMMOpacity cMMSetExcludeGI cMMExcludeGI =
	(
	if $ == undefined then (MessageBox "Please select at least one object." title:"coronaMaterialManager")
	else
		(
		local mats = sLibGetAllMaterialsOnSelectedObjects()
		local corMats = #()
		for m in mats do
			(
			try (if (classof m) == CoronaMtl then append corMats m) catch ()
			)
		if corMats.count == 0 then (MessageBox "No Corona materials found on selected objects." title:"coronaMaterialManager")
		else
			(
			for m in corMats do
				(
				try
					(
					if cMMSetDisp then
						(
						setProperty m "displacementMax" cMMDispAmount
						setProperty m "displacementOffset" cMMDispOffset
						)
					if cMMSetGloss then
						(
						setProperty m "glossiness" cMMGloss
						)
					if cMMSetReflGloss then
						(
						setProperty m "reflectionGlossiness" cMMReflGloss
						)
					if cMMSetOpacity then
						(
						setProperty m "opacity" cMMOpacity
						)
					if cMMSetExcludeGI then
						(
						setProperty m "excludeFromGI" cMMExcludeGI
						)
					) catch ()
				)
			MessageBox (corMats.count as string + " Corona material(s) updated.") title:"coronaMaterialManager"
			)
		)
	)

fn coronaMaterialManagerDefaults =
	(
	cMMLoadDef()
	coronaMaterialManager cMMSetDispValue cMMDispAmountValue cMMDispOffsetValue cMMSetGlossValue cMMGlossValue cMMSetReflGlossValue cMMReflGlossValue cMMSetOpacityValue cMMOpacityValue cMMSetExcludeGIValue cMMExcludeFromGIValue
	)

fn coronaMaterialManagerUI =
	(
	cMMLoadDef()
	cMMCloseOpenUI cMMPosValue
	)

fn cMMCloseOpenUI pos =
	(
	if cMMFloater != undefined then CloseRolloutFloater cMMFloater
	cMMDefineUI()
	cMMFloater = newRolloutFloater "coronaMaterialManager v1.00" 310 330 pos.x pos.y
	addRollout cMMRollout cMMFloater
	)

fn cMMHelp =
	(
	MessageBox "coronaMaterialManager: Batch-modify Corona Material properties.\nSelect objects with Corona materials, set values, hit Do." title:"coronaMaterialManager Help"
	)

fn cMMLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cMMInputFilename = presetDir + "coronaMaterialManager.ini"
	if (sLibFileExist cMMInputFilename == true) then
		(
		cMMSetDispValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMSetDispValue") == "true"
		cMMDispAmountValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMDispAmountValue") as float
		cMMDispOffsetValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMDispOffsetValue") as float
		cMMSetGlossValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMSetGlossValue") == "true"
		cMMGlossValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMGlossValue") as float
		cMMSetReflGlossValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMSetReflGlossValue") == "true"
		cMMReflGlossValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMReflGlossValue") as float
		cMMSetOpacityValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMSetOpacityValue") == "true"
		cMMOpacityValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMOpacityValue") as float
		cMMSetExcludeGIValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMSetExcludeGIValue") == "true"
		cMMExcludeFromGIValue = (getINISetting cMMInputFilename "coronaMaterialManager" "cMMExcludeFromGIValue") == "true"
		cMMPosValue = sLibGetINIPoint2 cMMInputFilename "coronaMaterialManager" "cMMPosValue" (sLibGetSafeUIPos 310 330)
		if cMMDispAmountValue == 0.0 then cMMDispAmountValue = 1.0
		if cMMGlossValue == 0.0 then cMMGlossValue = 1.0
		if cMMReflGlossValue == 0.0 then cMMReflGlossValue = 1.0
		if cMMOpacityValue == 0.0 then cMMOpacityValue = 1.0
		)
	else
		(
		cMMSetDispValue = false; cMMDispAmountValue = 1.0; cMMDispOffsetValue = 0.0
		cMMSetGlossValue = false; cMMGlossValue = 1.0
		cMMSetReflGlossValue = false; cMMReflGlossValue = 1.0
		cMMSetOpacityValue = false; cMMOpacityValue = 1.0
		cMMSetExcludeGIValue = false; cMMExcludeFromGIValue = false
		cMMPosValue = sLibGetSafeUIPos 310 330
		)
	)

fn cMMSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cMMOutputFilename = presetDir + "coronaMaterialManager.ini"
	if (sLibFileExist cMMOutputFilename == true) then deleteFile cMMOutputFilename
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMSetDispValue" (cMMSetDispValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMDispAmountValue" (cMMDispAmountValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMDispOffsetValue" (cMMDispOffsetValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMSetGlossValue" (cMMSetGlossValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMGlossValue" (cMMGlossValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMSetReflGlossValue" (cMMSetReflGlossValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMReflGlossValue" (cMMReflGlossValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMSetOpacityValue" (cMMSetOpacityValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMOpacityValue" (cMMOpacityValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMSetExcludeGIValue" (cMMSetExcludeGIValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMExcludeFromGIValue" (cMMExcludeFromGIValue as string)
	setINISetting cMMOutputFilename "coronaMaterialManager" "cMMPosValue" (cMMFloater.pos as string)
	)

-- UI

fn cMMDefineUI =
	(
	rollout cMMRollout "coronaMaterialManager"
		(
		group "Displacement"
			(
			checkbox cMMSetDispCheckbox "Set Displacement" checked:cMMSetDispValue align:#left
			spinner cMMDispAmountSpinner "Amount: " range:[0,99999,cMMDispAmountValue] fieldWidth:60 type:#float align:#right
			spinner cMMDispOffsetSpinner "Offset: " range:[-99999,99999,cMMDispOffsetValue] fieldWidth:60 type:#float align:#right
			)
		group "Glossiness"
			(
			checkbox cMMSetGlossCheckbox "Set Diffuse Glossiness" checked:cMMSetGlossValue align:#left
			spinner cMMGlossSpinner "Glossiness: " range:[0.0,1.0,cMMGlossValue] fieldWidth:60 type:#float align:#right
			checkbox cMMSetReflGlossCheckbox "Set Refl Glossiness" checked:cMMSetReflGlossValue align:#left
			spinner cMMReflGlossSpinner "Refl Gloss: " range:[0.0,1.0,cMMReflGlossValue] fieldWidth:60 type:#float align:#right
			)
		group "Opacity / GI"
			(
			checkbox cMMSetOpacityCheckbox "Set Opacity" checked:cMMSetOpacityValue align:#left
			spinner cMMOpacitySpinner "Opacity: " range:[0.0,1.0,cMMOpacityValue] fieldWidth:60 type:#float align:#right
			checkbox cMMSetExcludeGICheckbox "Set Exclude From GI" checked:cMMSetExcludeGIValue align:#left
			checkbox cMMExcludeFromGICheckbox "  Exclude From GI" checked:cMMExcludeFromGIValue align:#left
			)

		on cMMSetDispCheckbox changed s do cMMSetDispValue = s
		on cMMDispAmountSpinner changed v do cMMDispAmountValue = v
		on cMMDispOffsetSpinner changed v do cMMDispOffsetValue = v
		on cMMSetGlossCheckbox changed s do cMMSetGlossValue = s
		on cMMGlossSpinner changed v do cMMGlossValue = v
		on cMMSetReflGlossCheckbox changed s do cMMSetReflGlossValue = s
		on cMMReflGlossSpinner changed v do cMMReflGlossValue = v
		on cMMSetOpacityCheckbox changed s do cMMSetOpacityValue = s
		on cMMOpacitySpinner changed v do cMMOpacityValue = v
		on cMMSetExcludeGICheckbox changed s do cMMSetExcludeGIValue = s
		on cMMExcludeFromGICheckbox changed s do cMMExcludeFromGIValue = s

		button cMMDoButton "Do" width:80 align:#left across:3
		button cMMApplyButton "Apply" width:80 align:#center
		button cMMHelpButton "Help" width:50 align:#right
		on cMMDoButton pressed do
			(
			coronaMaterialManager cMMSetDispValue cMMDispAmountValue cMMDispOffsetValue cMMSetGlossValue cMMGlossValue cMMSetReflGlossValue cMMReflGlossValue cMMSetOpacityValue cMMOpacityValue cMMSetExcludeGIValue cMMExcludeFromGIValue
			if cMMFloater != undefined then CloseRolloutFloater cMMFloater
			)
		on cMMApplyButton pressed do
			coronaMaterialManager cMMSetDispValue cMMDispAmountValue cMMDispOffsetValue cMMSetGlossValue cMMGlossValue cMMSetReflGlossValue cMMReflGlossValue cMMSetOpacityValue cMMOpacityValue cMMSetExcludeGIValue cMMExcludeFromGIValue
		on cMMHelpButton pressed do cMMHelp()
		button cMMSaveDefButton "SaveDef" width:80 align:#center
		on cMMSaveDefButton pressed do cMMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------
