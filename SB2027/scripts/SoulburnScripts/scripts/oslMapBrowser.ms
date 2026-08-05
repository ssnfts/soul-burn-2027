-------------------------------------------------------------------------------
-- oslMapBrowser.ms
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
-- Browse OSL map (.osl / .oso) files from Max's OSL map directories,
-- and assign the selected OSL map to the currently active material slot.
-- Supports both default Max OSL paths and custom additional search paths.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global oslMapBrowserDefaults
global oslMapBrowserUI

global oSLCloseOpenUI
global oSLScanDirs
global oSLApplyMap
global oSLHelp
global oSLLoadDef
global oSLSaveDef
global oSLDefineUI
global oSLRollout
global oSLFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
oSLSearchPathValue = ""
oSLMeditModeValue = 1  -- 1=Compact Medit, 2=Slate Medit
oSLPosValue = sLibGetSafeUIPos 320 460

global oSLFileList = #()
global oSLFileNameList = #()

-- Functions

fn oSLScanDirs =
	(
	oSLFileList = #()
	oSLFileNameList = #()
	-- Default Max OSL paths
	local maxRoot = symbolicPaths.getPathValue "$max"
	local defaultPaths = #(
		(maxRoot + "\\maps\\OSL\\"),
		(maxRoot + "\\OSL\\")
	)
	-- Add user custom path if set
	if oSLSearchPathValue != "" then append defaultPaths oSLSearchPathValue
	for dir in defaultPaths do
		(
		if doesFileExist dir then
			(
			local osls = sLibGetAllFilesInDir dir true "osl"
			local osos = sLibGetAllFilesInDir dir true "oso"
			join oSLFileList osls
			join oSLFileList osos
			)
		)
	for f in oSLFileList do append oSLFileNameList (sLibFilenameFromPath f)
	)

fn oSLApplyMap selectedIdx meditMode =
	(
	if selectedIdx < 1 or selectedIdx > oSLFileList.count then
		(
		MessageBox "Please select an OSL map from the list." title:"oslMapBrowser"
		return false
		)
	local oslPath = oSLFileList[selectedIdx]
	if not (doesFileExist oslPath) then
		(
		MessageBox ("File not found: " + oslPath) title:"oslMapBrowser"
		return false
		)
	-- Create OSLMap and set path
	local newMap = OSLMap()
	newMap.OSLPath = oslPath
	newMap.name = oSLFileNameList[selectedIdx]
	-- Get active map slot from material editor
	local activeMap = sLibGetActiveMap meditMode
	if activeMap == undefined then
		(
		-- If no map slot active, put in slot 1 of compact medit
		meditmaterials[1] = newMap
		)
	else
		(
		-- Replace the active map's slot with the new OSL map
		-- This assigns it into whatever slot is currently shown
		local curMat = medit.GetCurMtl()
		if curMat != undefined and superclassof curMat == material then
			meditmaterials[medit.slot] = newMap
		else
			meditmaterials[1] = newMap
		)
	MessageBox ("Applied OSL map: " + oSLFileNameList[selectedIdx]) title:"oslMapBrowser"
	return true
	)

fn oslMapBrowserDefaults =
	(
	oSLLoadDef()
	)

fn oslMapBrowserUI =
	(
	oSLLoadDef()
	oSLCloseOpenUI oSLPosValue
	)

fn oSLCloseOpenUI pos =
	(
	if oSLFloater != undefined then CloseRolloutFloater oSLFloater
	oSLScanDirs()
	oSLDefineUI()
	oSLFloater = newRolloutFloater "oslMapBrowser v1.00" 320 460 pos.x pos.y
	addRollout oSLRollout oSLFloater
	)

fn oSLHelp =
	(
	MessageBox "oslMapBrowser: Browse OSL maps in Max's OSL directories.\nSelect an OSL map and click Apply to assign it to the active material slot in the Material Editor.\nUse Refresh to rescan directories after adding new .osl files." title:"oslMapBrowser Help"
	)

fn oSLLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	oSLInputFilename = presetDir + "oslMapBrowser.ini"
	if (sLibFileExist oSLInputFilename == true) then
		(
		oSLSearchPathValue = getINISetting oSLInputFilename "oslMapBrowser" "oSLSearchPathValue"
		oSLMeditModeValue = (getINISetting oSLInputFilename "oslMapBrowser" "oSLMeditModeValue") as integer
		oSLPosValue = sLibGetINIPoint2 oSLInputFilename "oslMapBrowser" "oSLPosValue" (sLibGetSafeUIPos 320 460)
		if oSLSearchPathValue == "" then oSLSearchPathValue = ""
		if oSLMeditModeValue == 0 then oSLMeditModeValue = 1
		)
	else
		(
		oSLSearchPathValue = ""
		oSLMeditModeValue = 1
		oSLPosValue = sLibGetSafeUIPos 320 460
		)
	)

fn oSLSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	oSLOutputFilename = presetDir + "oslMapBrowser.ini"
	if (sLibFileExist oSLOutputFilename == true) then deleteFile oSLOutputFilename
	setINISetting oSLOutputFilename "oslMapBrowser" "oSLSearchPathValue" oSLSearchPathValue
	setINISetting oSLOutputFilename "oslMapBrowser" "oSLMeditModeValue" (oSLMeditModeValue as string)
	setINISetting oSLOutputFilename "oslMapBrowser" "oSLPosValue" (oSLFloater.pos as string)
	)

-- UI

fn oSLDefineUI =
	(
	rollout oSLRollout "oslMapBrowser"
		(
		group "OSL Files Found: "
			(
			listbox oSLListbox "" items:oSLFileNameList height:16 width:280
			)
		group "Options"
			(
			edittext oSLSearchPathEdit "Custom Path: " fieldWidth:190 text:oSLSearchPathValue align:#right
			dropdownlist oSLMeditModeDropdown "Medit Mode: " items:#("Compact Medit","Slate Medit") selection:oSLMeditModeValue width:130 align:#right
			)

		on oSLSearchPathEdit changed t do oSLSearchPathValue = t
		on oSLMeditModeDropdown selected i do oSLMeditModeValue = i

		button oSLRefreshButton "Refresh" width:80 align:#left across:3
		button oSLApplyButton "Apply to Medit" width:120 align:#center
		button oSLHelpButton "Help" width:50 align:#right
		on oSLRefreshButton pressed do
			(
			local curPos = oSLFloater.pos
			oSLCloseOpenUI curPos
			)
		on oSLApplyButton pressed do
			oSLApplyMap oSLListbox.selection oSLMeditModeValue
		on oSLHelpButton pressed do oSLHelp()
		button oSLSaveDefButton "SaveDef" width:80 align:#center
		on oSLSaveDefButton pressed do oSLSaveDef()

		on oSLRollout open do
			(
			if oSLFileList.count == 0 then
				MessageBox ("No .osl or .oso files found.\nCheck your Max install path or set a Custom Path.\n\nSearched:\n" + (maxVersion())[1] as string) title:"oslMapBrowser"
			)
		)
	)
)
-------------------------------------------------------------------------------
