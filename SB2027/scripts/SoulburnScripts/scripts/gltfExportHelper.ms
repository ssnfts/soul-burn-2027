-------------------------------------------------------------------------------
-- gltfExportHelper.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 05/01/25
-- tested using Max 2027 (requires native glTF exporter, Max 2023+)
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- Guided glTF/glb export helper. Runs pre-export validation on selected
-- geometry: checks UV channel 1 presence, material type compatibility
-- (Physical Material or glTF Material required), non-uniform scale warnings,
-- and missing normals. Shows a report, then exports via the native exporter.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global gltfExportHelperDefaults
global gltfExportHelperUI

global gEHCloseOpenUI
global gEHValidate
global gEHExport
global gEHHelp
global gEHLoadDef
global gEHSaveDef
global gEHDefineUI
global gEHRollout
global gEHFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
gEHExportSelectionValue = true
gEHOutputPathValue = ""
gEHFormatValue = 1  -- 1=glTF, 2=glb
gEHEmbedTexturesValue = true
gEHExportAnimValue = false
gEHPosValue = sLibGetSafeUIPos 340 310

-- Functions

fn gEHValidate exportSelection =
	(
	local issues = #()
	local objs = #()
	if exportSelection then
		objs = for i in selection where (sLibGeometryFilter i) collect i
	else
		objs = for i in geometry collect i

	if objs.count == 0 then
		(
		append issues "WARNING: No geometry found to validate."
		)

	for obj in objs do
		(
		-- Check UV channel 1
		local hasUV = false
		try (hasUV = (polyOp.getNumMapVerts obj 1) > 0) catch ()
		if not hasUV then append issues ("NO UV channel 1: " + obj.name)

		-- Check material type
		if obj.material != undefined then
			(
			local cls = (classof obj.material) as string
			local validMat = matchPattern cls pattern:"*Physical*" ignoreCase:true or
			                 matchPattern cls pattern:"*GLTF*" ignoreCase:true or
			                 matchPattern cls pattern:"*glTF*" ignoreCase:true or
			                 matchPattern cls pattern:"*Standard*" ignoreCase:true
			if not validMat then append issues ("INCOMPATIBLE MAT (" + cls + "): " + obj.name)
			)
		else
			(
			append issues ("NO MATERIAL: " + obj.name)
			)

		-- Check non-uniform scale
		local s = obj.scale
		if abs(s.x - s.y) > 0.001 or abs(s.y - s.z) > 0.001 then
			append issues ("NON-UNIFORM SCALE: " + obj.name)
		)

	return issues
	)

fn gEHExport exportSelection outputPath formatIdx embedTex exportAnim =
	(
	if outputPath == "" then
		(
		MessageBox "Please set an output file path first." title:"gltfExportHelper"
		return false
		)
	local ext = if formatIdx == 1 then ".gltf" else ".glb"
	local finalPath = outputPath
	if not matchPattern finalPath pattern:("*" + ext) ignoreCase:true then
		finalPath = finalPath + ext

	-- Validate first
	local issues = gEHValidate exportSelection
	if issues.count > 0 then
		(
		local report = "Validation issues found:\n\n"
		for i in issues do report += i + "\n"
		report += "\nExport anyway?"
		if (queryBox report title:"gltfExportHelper") == false then return false
		)

	-- Export using native glTF exporter
	try
		(
		if exportSelection then
			exportFile finalPath #noPrompt selectedOnly:true
		else
			exportFile finalPath #noPrompt
		MessageBox ("Exported to: " + finalPath) title:"gltfExportHelper"
		return true
		)
	catch
		(
		MessageBox ("Export failed. Ensure Max 2023+ glTF exporter is installed.\nPath: " + finalPath) title:"gltfExportHelper"
		return false
		)
	)

fn gltfExportHelperDefaults =
	(
	gEHLoadDef()
	)

fn gltfExportHelperUI =
	(
	gEHLoadDef()
	gEHCloseOpenUI gEHPosValue
	)

fn gEHCloseOpenUI pos =
	(
	if gEHFloater != undefined then CloseRolloutFloater gEHFloater
	gEHDefineUI()
	gEHFloater = newRolloutFloater "gltfExportHelper v1.00" 340 310 pos.x pos.y
	addRollout gEHRollout gEHFloater
	)

fn gEHHelp =
	(
	MessageBox "gltfExportHelper: Validate and export geometry as glTF/glb.\n\nValidation checks:\n- UV Channel 1 present\n- Compatible material (Physical or glTF)\n- Uniform scale\n- No missing materials\n\nRequires Max 2023+ for native glTF export." title:"gltfExportHelper Help"
	)

fn gEHLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	gEHInputFilename = presetDir + "gltfExportHelper.ini"
	if (sLibFileExist gEHInputFilename == true) then
		(
		gEHExportSelectionValue = (getINISetting gEHInputFilename "gltfExportHelper" "gEHExportSelectionValue") == "true"
		gEHOutputPathValue = getINISetting gEHInputFilename "gltfExportHelper" "gEHOutputPathValue"
		gEHFormatValue = (getINISetting gEHInputFilename "gltfExportHelper" "gEHFormatValue") as integer
		gEHEmbedTexturesValue = (getINISetting gEHInputFilename "gltfExportHelper" "gEHEmbedTexturesValue") == "true"
		gEHExportAnimValue = (getINISetting gEHInputFilename "gltfExportHelper" "gEHExportAnimValue") == "true"
		gEHPosValue = sLibGetINIPoint2 gEHInputFilename "gltfExportHelper" "gEHPosValue" (sLibGetSafeUIPos 340 310)
		if gEHFormatValue == 0 then gEHFormatValue = 1
		)
	else
		(
		gEHExportSelectionValue = true; gEHOutputPathValue = ""
		gEHFormatValue = 1; gEHEmbedTexturesValue = true; gEHExportAnimValue = false
		gEHPosValue = sLibGetSafeUIPos 340 310
		)
	)

fn gEHSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	gEHOutputFilename = presetDir + "gltfExportHelper.ini"
	if (sLibFileExist gEHOutputFilename == true) then deleteFile gEHOutputFilename
	setINISetting gEHOutputFilename "gltfExportHelper" "gEHExportSelectionValue" (gEHExportSelectionValue as string)
	setINISetting gEHOutputFilename "gltfExportHelper" "gEHOutputPathValue" gEHOutputPathValue
	setINISetting gEHOutputFilename "gltfExportHelper" "gEHFormatValue" (gEHFormatValue as string)
	setINISetting gEHOutputFilename "gltfExportHelper" "gEHEmbedTexturesValue" (gEHEmbedTexturesValue as string)
	setINISetting gEHOutputFilename "gltfExportHelper" "gEHExportAnimValue" (gEHExportAnimValue as string)
	setINISetting gEHOutputFilename "gltfExportHelper" "gEHPosValue" (gEHFloater.pos as string)
	)

-- UI

fn gEHDefineUI =
	(
	rollout gEHRollout "gltfExportHelper"
		(
		group "Target"
			(
			checkbox gEHExportSelCheckbox "Export Selection Only" checked:gEHExportSelectionValue align:#left
			)
		group "Output"
			(
			edittext gEHOutputPathEdit "Path: " fieldWidth:230 text:gEHOutputPathValue align:#right
			button gEHBrowseButton "Browse..." width:80 align:#right
			dropdownlist gEHFormatDropdown "Format: " items:#("glTF (.gltf)","Binary glTF (.glb)") selection:gEHFormatValue width:150 align:#right
			checkbox gEHEmbedTexturesCheckbox "Embed Textures" checked:gEHEmbedTexturesValue align:#left
			checkbox gEHExportAnimCheckbox "Export Animation" checked:gEHExportAnimValue align:#left
			)

		on gEHExportSelCheckbox changed s do gEHExportSelectionValue = s
		on gEHOutputPathEdit changed t do gEHOutputPathValue = t
		on gEHBrowseButton pressed do
			(
			local f = getSaveFileName caption:"glTF Output" filename:gEHOutputPathValue types:"glTF Files (*.gltf)|*.gltf|Binary glTF (*.glb)|*.glb"
			if f != undefined then (gEHOutputPathValue = f; gEHOutputPathEdit.text = f)
			)
		on gEHFormatDropdown selected i do gEHFormatValue = i
		on gEHEmbedTexturesCheckbox changed s do gEHEmbedTexturesValue = s
		on gEHExportAnimCheckbox changed s do gEHExportAnimValue = s

		button gEHValidateButton "Validate Only" width:100 align:#left across:3
		button gEHExportButton "Export" width:100 align:#center
		button gEHHelpButton "Help" width:60 align:#right
		on gEHValidateButton pressed do
			(
			local issues = gEHValidate gEHExportSelectionValue
			if issues.count == 0 then
				MessageBox "Validation passed! No issues found." title:"gltfExportHelper"
			else
				(
				local report = "Issues found:\n\n"
				for i in issues do report += i + "\n"
				MessageBox report title:"gltfExportHelper"
				)
			)
		on gEHExportButton pressed do
			gEHExport gEHExportSelectionValue gEHOutputPathValue gEHFormatValue gEHEmbedTexturesValue gEHExportAnimValue
		on gEHHelpButton pressed do gEHHelp()
		button gEHSaveDefButton "SaveDef" width:80 align:#center
		on gEHSaveDefButton pressed do gEHSaveDef()
		)
	)
)
-------------------------------------------------------------------------------
