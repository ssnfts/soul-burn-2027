-------------------------------------------------------------------------------
-- vrayMatteManager.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 2.00
-- Created On: 03/05/19
-- Modified On: 05/22/19
-- tested using Max 2027 + V-Ray 6/7
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Allows you to turn on or turn off the shadow catching Matte properites of
-- selected objects for vray.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Select a set of objects. Run the UI version of the script. Hit Do. It will 
-- turn all selected objects into shadow catchers. Change the dropdown. Hit Do.
-- It will turn off the shadow catching properties, returning the objects to 
-- normal.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Added ability to make objects a matte object with no shadow catching 
-- ability.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vrayMatteManager
global vrayMatteManagerDefaults
global vrayMatteManagerUI

global vMMCloseOpenUI

global vMMDo
global vMMApply
global vMMHelp
global vMMLoadDef
global vMMSaveDef

global vMMDefineUI
global vMMRollout
global vMMFloater

-- Includes

include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vMMActionValue = 1
vMMPosValue = sLibGetSafeUIPos 310 91

-- Functions

-- v2.00: The VRay_Matte_* user properties are still how V-Ray 6/7 store
-- per-object matte settings, so that path is unchanged. What was missing is a
-- renderer check: under Arnold or Corona these properties are written but
-- never read, so the tool silently did nothing. Warn instead.

fn vrayMatteManager vMMAction =
	(
	local rend = sLibWhatsCurrentRenderer()
	if rend != "vray" then
		(
		if not (queryBox ("Current renderer is '" + rend + "', not V-Ray.\n\nThe VRay_Matte_* object properties this tool writes are only read by V-Ray - under " + rend + " they will have no effect.\n\nWrite them anyway?") title:"vrayMatteManager") then return false
		)
	if selection.count == 0 then
		(
		MessageBox "Select one or more objects first." title:"vrayMatteManager"
		return false
		)
	for obj in selection do
		(
		if vMMAction == 1 then
			(
			setUserProp obj "VRay_Matte_Enable" true
			setUserProp obj "VRay_Secondary_Matte_Enable" true
			setUserProp obj "VRay_Matte_Alpha" -1.0
			setUserProp obj "VRay_Matte_Shadows" true
			setUserProp obj "VRay_Matte_ShadowAlpha" true
			)
		else if vMMAction == 2 then
			(
			setUserProp obj "VRay_Matte_Enable" true
			setUserProp obj "VRay_Secondary_Matte_Enable" true
			setUserProp obj "VRay_Matte_Alpha" -1.0
			setUserProp obj "VRay_Matte_Shadows" false
			setUserProp obj "VRay_Matte_ShadowAlpha" false
			)
		else if vMMAction == 3 then
			(
			setUserProp obj "VRay_Matte_Enable" false
			setUserProp obj "VRay_Secondary_Matte_Enable" false
			setUserProp obj "VRay_Matte_Alpha" 1.0
			setUserProp obj "VRay_Matte_Shadows" false
			setUserProp obj "VRay_Matte_ShadowAlpha" false
			)
		)
	)
	
fn vrayMatteManagerDefaults = 
	(
	vMMLoadDef()
	vrayMatteManager vMMActionValue
	)
	
fn vrayMatteManagerUI = 
	(
	vMMLoadDef()
	vMMCloseOpenUI vMMPosValue
	)

fn vMMCloseOpenUI pos = 
	(
	if vMMFloater != undefined then CloseRolloutFloater vMMFloater
	vMMDefineUI()
	vMMFloater = newRolloutFloater "vrayMatteManager v2.00" 310 91 pos.x pos.y
	addRollout vMMRollout vMMFloater
	)

fn vMMDo = 
	(
	vrayMatteManager vMMActionValue
	if vMMFloater != undefined then CloseRolloutFloater vMMFloater
	)

fn vMMApply = 
	(
	vrayMatteManager vMMActionValue
	)
	
fn vMMHelp = 
	(
	sLibSSPrintHelp "vrayMatteManager"
	)
	
fn vMMLoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vMMInputFilename = presetDir + "vrayMatteManager.ini"
	if (sLibFileExist vMMInputFilename == true) then
		(
		vMMActionValue = sLibGetINIInteger vMMInputFilename "vrayMatteManager" "vMMActionValue" 1
		vMMPosValue = sLibGetINIPoint2 vMMInputFilename "vrayMatteManager" "vMMPosValue" (sLibGetSafeUIPos 310 91)
		
		)
	else
		(
		vMMActionValue = 1
		vMMPosValue = sLibGetSafeUIPos 310 91
		)
	)
	
fn vMMSaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vMMOutputFilename = presetDir + "vrayMatteManager.ini"
	if (sLibFileExist vMMOutputFilename == true) then deleteFile vMMOutputFilename
	setINISetting vMMOutputFilename "vrayMatteManager" "vMMActionValue" (vMMActionValue as string)
	setINISetting vMMOutputFilename "vrayMatteManager" "vMMPosValue" (vMMFloater.pos as string)
	)

-- UI

fn vMMDefineUI = 
	(
	rollout vMMRollout "vrayMatteManager"
		(
		label label1 "Action:" pos:[10,10]
		dropdownlist vMMActionDropdown "" items:#("Turn Selection Into Shadow Catchers", "Turn Selection Into Matte Objects", "Turn off Matte / Shadow Properties Of Selection") selection:vMMActionValue pos:[50,7] width:237
		on vMMActionDropdown selected i do vMMActionValue = i

		button vMMDoButton "Do" width:70 toolTip:"Do It and Close UI" pos:[5,34]
		on vMMDoButton pressed do vMMDo()
		button vMMApplyButton "Apply" width:70 toolTip:"Do It and Keep UI Open" pos:[77,34]
		on vMMApplyButton pressed do vMMApply()
		button vMMHelpButton "Help" width:70 toolTip:"Help" pos:[149,34]
		on vMMHelpButton pressed do vMMHelp()
		button vMMSaveDefButton "SaveDef" width:70 toolTip:"Save Current Settings as Default" pos:[221,34]
		on vMMSaveDefButton pressed do vMMSaveDef()
		)
	)
)
-------------------------------------------------------------------------------