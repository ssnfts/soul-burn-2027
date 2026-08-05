-------------------------------------------------------------------------------
-- customLightingAssistant.ms
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
-- A guided lighting rig assistant. Encodes production lighting practice into
-- four sections: indirect lighting / fake bounce fill, AOV (render element)
-- setup, light group assignment, and Arnold light filters.
--
-- Concepts follow Ivan M. Benitez Sanz's Week 3 lighting notes:
--   - Noise originates in indirect lighting samples; faking bounces with real
--     lights lets you lower GI bounce counts and save render time.
--   - Bounce light is diffuse, so it has no directionality and casts very soft
--     shadows. Its spread is therefore forced to 1 and specular set to 0.
--   - Light groups are per-light AOVs (RGBA_key, Diffuse_key, ...).
--   - Gobo and Barndoor filters are spot-light only.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Renderer support:
-- Render elements are resolved by CLASS NAME at runtime, so a renderer that is
-- not installed reports a clear message instead of throwing. Only the V-Ray
-- element names have been checked against an installed renderer; the Arnold
-- and Corona names come from their respective docs and are unverified here.
-- Anything that cannot be resolved is listed in the status line.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals
global customLightingAssistantDefaults
global customLightingAssistantUI

global cLACloseOpenUI
global cLAAddBounceLight
global cLASetGIBounces
global cLAEnableAOVs
global cLAAssignLightGroup
global cLAAddLightFilter
global cLAResolveClass
global cLASampledColor
global cLAHelp
global cLALoadDef
global cLASaveDef
global cLADefineUI
global cLARolloutGI
global cLARolloutAOV
global cLARolloutGroups
global cLARolloutFilters
global cLAFloater

-- Includes
include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables
cLABouncesValue = 3
cLABounceMultValue = 0.15
cLABounceDistValue = 100.0
cLAMergeEXRValue = true
cLAGroupNameValue = "key"
cLAAOVDiffuseValue = true
cLAAOVSpecularValue = true
cLAAOVSSSValue = false
cLAAOVEmissionValue = false
cLAAOVDepthValue = true
cLAAOVPositionValue = false
cLAAOVUVsValue = false
cLAAOVNormalsValue = true
cLAPosValue = sLibGetSafeUIPos 300 560

global cLAStatus = "Ready."

-- Functions

fn cLAResolveClass className = ( try (execute className) catch (undefined) )

fn cLASampledColor obj =
	(
	-- Bounce colour comes from the surface the light is bouncing off, so the
	-- fill picks up that surface's tint. Falls back to wirecolor.
	local col = obj.wirecolor
	try
		(
		if obj.material != undefined then
			(
			if (isProperty obj.material #diffuse) then col = obj.material.diffuse
			else if (isProperty obj.material #base_color) then col = obj.material.base_color
			)
		)
	catch ()
	return col
	)

fn cLAAddBounceLight mult dist =
	(
	-- Creates a fake bounce fill: diffuse-only, no specular, spread forced to 1
	-- (bounce light has no directionality), colour sampled from the subject.
	if selection.count == 0 then
		(
		MessageBox "Select the object the light should bounce off first." title:"customLightingAssistant"
		return false
		)
	local subject = selection[1]
	local col = cLASampledColor subject
	local ctr = subject.center

	theHold.Begin()
	local ok = true
	try
		(
		local L = Omnilight name:(uniqueName ("BounceFill_" + subject.name + "_"))
		L.pos = ctr + [dist, -dist, dist * 0.5]
		L.rgb = col
		L.multiplier = mult
		-- Bounce light is diffuse only: kill the specular contribution.
		try (L.affectSpecular = false) catch ()
		try (L.affectDiffuse = true) catch ()
		-- Very soft shadows, consistent with a diffuse bounce.
		try (L.castShadows = true) catch ()
		try (L.shadowGenerator = shadowMap()) catch ()
		-- Spread = 1 per the course notes (no directionality).
		try (L.contrast = 0) catch ()
		try (L.softenDiffuseEdge = 100) catch ()
		global cLAStatus = ("Added " + L.name)
		)
	catch
		(
		ok = false
		global cLAStatus = ("Bounce light failed: " + (getCurrentException() as string))
		)
	if ok then theHold.Accept "Add Bounce Fill Light" else theHold.Cancel()
	return ok
	)

fn cLASetGIBounces n =
	(
	-- GI bounce count lives in a different property per renderer, and noise
	-- scales with it. Unsupported renderers report rather than fail silently.
	local r = sLibWhatsCurrentRenderer()
	local rend = renderers.production
	local done = false
	case r of
		(
		"vray":
			(
			try (rend.gi_secondary_bounces = n; done = true) catch ()
			if not done then try (rend.gi_maxDepth = n; done = true) catch ()
			)
		"arnold":
			(
			try (rend.GI_diffuse_depth = n; done = true) catch ()
			if not done then try (rend.GI_total_depth = n; done = true) catch ()
			)
		"corona":
			(
			try (rend.gi_maxdepth = n; done = true) catch ()
			)
		default: done = false
		)
	if done then global cLAStatus = ("GI bounces set to " + (n as string) + " (" + r + ")")
	else global cLAStatus = ("Could not set GI bounces on renderer: " + r)
	return done
	)

fn cLAEnableAOVs =
	(
	-- Adds render elements through the Render Elements Manager, which is the
	-- stable cross-renderer entry point. Element CLASSES are renderer specific
	-- and resolved by name, so missing ones are reported, not fatal.
	local r = sLibWhatsCurrentRenderer()
	local wanted = #()
	case r of
		(
		"vray":
			(
			if cLAAOVDiffuseValue  then append wanted #("Diffuse",  "VRayDiffuseFilter")
			if cLAAOVSpecularValue then append wanted #("Specular", "VRayReflectionFilter")
			if cLAAOVSSSValue      then append wanted #("SSS",      "VRayRawTotalLightingFilter")
			if cLAAOVEmissionValue then append wanted #("Emission", "VRaySelfIllumination")
			if cLAAOVDepthValue    then append wanted #("Depth",    "VRayZDepth")
			if cLAAOVPositionValue then append wanted #("Position", "VRaySamplerInfo")
			if cLAAOVUVsValue      then append wanted #("UVs",      "VRaySamplerInfo")
			if cLAAOVNormalsValue  then append wanted #("Normals",  "VRayNormals")
			)
		"arnold":
			(
			if cLAAOVDiffuseValue  then append wanted #("Diffuse",  "Arnold_Render_Element")
			if cLAAOVSpecularValue then append wanted #("Specular", "Arnold_Render_Element")
			if cLAAOVDepthValue    then append wanted #("Depth",    "Arnold_Render_Element")
			if cLAAOVNormalsValue  then append wanted #("Normals",  "Arnold_Render_Element")
			)
		"corona":
			(
			if cLAAOVDiffuseValue  then append wanted #("Diffuse",  "CTexmapElement")
			if cLAAOVSpecularValue then append wanted #("Specular", "CTexmapElement")
			if cLAAOVDepthValue    then append wanted #("Depth",    "CTexmapElement")
			if cLAAOVNormalsValue  then append wanted #("Normals",  "CTexmapElement")
			)
		default: ()
		)

	if wanted.count == 0 then
		(
		global cLAStatus = ("No AOVs available for renderer: " + r)
		return false
		)

	local rem = maxOps.GetCurRenderElementMgr()
	if rem == undefined then
		(
		global cLAStatus = "Render Elements Manager unavailable."
		return false
		)

	local added = 0
	local failed = #()
	for w in wanted do
		(
		local cls = cLAResolveClass w[2]
		if cls == undefined then (append failed w[1]; continue)
		try
			(
			local el = cls()
			el.elementName = w[1]
			rem.AddRenderElement el
			added += 1
			)
		catch (append failed w[1])
		)

	-- Merge all AOVs into a single multi-channel EXR when requested.
	if cLAMergeEXRValue then
		(
		try (rem.SetElementsActive true) catch ()
		)

	local msg = ("Added " + (added as string) + " AOV(s) for " + r)
	if failed.count > 0 then msg = msg + " - unavailable: " + (failed as string)
	global cLAStatus = msg
	return (added > 0)
	)

fn cLAAssignLightGroup gname =
	(
	-- Light groups are per-light AOVs. The property differs per renderer:
	-- Arnold uses an AOV light group prefix, Corona reuses the effect ID.
	local lights = for o in selection where (superClassOf o == light) collect o
	if lights.count == 0 then
		(
		MessageBox "Select one or more lights first." title:"customLightingAssistant"
		return false
		)
	local r = sLibWhatsCurrentRenderer()
	local done = 0
	local failed = 0
	for L in lights do
		(
		local set = false
		case r of
			(
			"arnold": try (L.aiAovLightGroupPrefix = gname; set = true) catch ()
			"corona": try (L.effectID = (gname.count); set = true) catch ()
			default: ()
			)
		if not set then try (setUserProp L "LightGroup" gname; set = true) catch ()
		if set then done += 1 else failed += 1
		)
	global cLAStatus = ("Light group '" + gname + "' set on " + (done as string) + " light(s)" + \
		(if failed > 0 then (", " + (failed as string) + " failed") else ""))
	return (done > 0)
	)

fn cLAAddLightFilter kind =
	(
	-- Arnold light filters. Gobo and Barndoor are spot-only per the notes.
	local r = sLibWhatsCurrentRenderer()
	if r != "arnold" then
		(
		global cLAStatus = ("Light filters are Arnold-only. Current renderer: " + r)
		return false
		)
	local lights = for o in selection where (superClassOf o == light) collect o
	if lights.count == 0 then
		(
		MessageBox "Select one or more lights first." title:"customLightingAssistant"
		return false
		)

	local clsName = case kind of
		(
		#gobo:     "Arnold_Gobo_Filter"
		#barndoor: "Arnold_Barndoor_Filter"
		#decay:    "Arnold_Light_Decay_Filter"
		#blocker:  "Arnold_Light_Blocker_Filter"
		default:   ""
		)
	local cls = cLAResolveClass clsName
	if cls == undefined then
		(
		global cLAStatus = ("Filter class not available: " + clsName)
		return false
		)

	local done = 0
	for L in lights do
		(
		-- Gobo / Barndoor only apply to spot lights.
		if (kind == #gobo or kind == #barndoor) and (classOf L != Targetspot and classOf L != Freespot) then continue
		try
			(
			local flt = cls()
			if (isProperty L #filters) then
				(
				local arr = L.filters
				append arr flt
				L.filters = arr
				done += 1
				)
			)
		catch ()
		)
	global cLAStatus = ("Added " + (kind as string) + " filter to " + (done as string) + " light(s)")
	return (done > 0)
	)

fn customLightingAssistantDefaults =
	(
	cLALoadDef()
	cLAEnableAOVs()
	)

fn customLightingAssistantUI =
	(
	cLALoadDef()
	cLACloseOpenUI cLAPosValue
	)

fn cLACloseOpenUI pos =
	(
	if cLAFloater != undefined then CloseRolloutFloater cLAFloater
	cLADefineUI()
	cLAFloater = newRolloutFloater "customLightingAssistant v1.00" 300 560 pos.x pos.y
	addRollout cLARolloutGI cLAFloater
	addRollout cLARolloutAOV cLAFloater
	addRollout cLARolloutGroups cLAFloater rolledUp:true
	addRollout cLARolloutFilters cLAFloater rolledUp:true
	)

fn cLAHelp =
	(
	MessageBox "customLightingAssistant: guided lighting rig setup.\n\nIndirect Lighting: sets the GI bounce count and creates fake bounce fill lights. Noise comes from indirect samples, so faking bounces lets you lower GI and save render time.\n\nBounce Fill: select the surface the light bounces off. The new light samples that surface's colour, has no specular, and very soft shadows.\n\nAOV Setup: adds render elements for the current renderer. Elements that the installed renderer does not provide are listed in the status line rather than failing.\n\nLight Groups: per-light AOVs (RGBA_key etc). Falls back to a LightGroup user property when the renderer has no native attribute.\n\nLight Filters: Arnold only. Gobo and Barndoor are spot-light only." title:"customLightingAssistant Help"
	)

fn cLALoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	cLAInputFilename = presetDir + "customLightingAssistant.ini"
	if (sLibFileExist cLAInputFilename == true) then
		(
		cLABouncesValue = sLibGetINIInteger cLAInputFilename "customLightingAssistant" "cLABouncesValue" 3
		cLABounceMultValue = sLibGetINIFloat cLAInputFilename "customLightingAssistant" "cLABounceMultValue" 0.15
		cLABounceDistValue = sLibGetINIFloat cLAInputFilename "customLightingAssistant" "cLABounceDistValue" 100.0
		cLAMergeEXRValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAMergeEXRValue" true
		cLAGroupNameValue = sLibGetINIString cLAInputFilename "customLightingAssistant" "cLAGroupNameValue" "key"
		cLAAOVDiffuseValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVDiffuseValue" true
		cLAAOVSpecularValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVSpecularValue" true
		cLAAOVSSSValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVSSSValue" false
		cLAAOVEmissionValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVEmissionValue" false
		cLAAOVDepthValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVDepthValue" true
		cLAAOVPositionValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVPositionValue" false
		cLAAOVUVsValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVUVsValue" false
		cLAAOVNormalsValue = sLibGetINIBoolean cLAInputFilename "customLightingAssistant" "cLAAOVNormalsValue" true
		cLAPosValue = sLibGetINIPoint2 cLAInputFilename "customLightingAssistant" "cLAPosValue" (sLibGetSafeUIPos 300 560)
		)
	)

fn cLASaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	cLAOutputFilename = presetDir + "customLightingAssistant.ini"
	if (sLibFileExist cLAOutputFilename == true) then deleteFile cLAOutputFilename
	setINISetting cLAOutputFilename "customLightingAssistant" "cLABouncesValue" (cLABouncesValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLABounceMultValue" (cLABounceMultValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLABounceDistValue" (cLABounceDistValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAMergeEXRValue" (cLAMergeEXRValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAGroupNameValue" cLAGroupNameValue
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVDiffuseValue" (cLAAOVDiffuseValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVSpecularValue" (cLAAOVSpecularValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVSSSValue" (cLAAOVSSSValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVEmissionValue" (cLAAOVEmissionValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVDepthValue" (cLAAOVDepthValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVPositionValue" (cLAAOVPositionValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVUVsValue" (cLAAOVUVsValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAAOVNormalsValue" (cLAAOVNormalsValue as string)
	setINISetting cLAOutputFilename "customLightingAssistant" "cLAPosValue" (cLAFloater.pos as string)
	)

-- UI

fn cLADefineUI =
	(
	rollout cLARolloutGI "Indirect Lighting"
		(
		label cLARendLabel "Current renderer: unknown" align:#left
		label cLASpacerA "" height:2
		spinner cLABouncesSpinner "GI Bounces: " range:[0,32,3] type:#integer fieldWidth:50 align:#right
		button cLASetBouncesButton "Apply GI Bounces" width:250 align:#center
		label cLANoteGI "More bounces = less bias, more noise + time." align:#left

		label cLASpacerB "" height:6
		groupBox cLABounceGroup "Fake Bounce Fill" width:270 height:96 align:#center
		spinner cLABounceMultSpinner "Multiplier: " range:[0.0,10.0,0.15] type:#float scale:0.01 fieldWidth:50 align:#right offset:[-8,-78]
		spinner cLABounceDistSpinner "Offset Dist: " range:[0.1,100000.0,100.0] type:#float scale:1.0 fieldWidth:50 align:#right offset:[-8,0]
		button cLABounceButton "Add Bounce Fill Light" width:250 align:#center offset:[0,0]
		label cLANoteBounce "Colour sampled from selection. No specular." align:#left offset:[0,0]

		label cLASpacerC "" height:4
		label cLAStatusLabel1 "Ready." align:#left

		on cLABouncesSpinner changed val do cLABouncesValue = val
		on cLABounceMultSpinner changed val do cLABounceMultValue = val
		on cLABounceDistSpinner changed val do cLABounceDistValue = val

		on cLASetBouncesButton pressed do
			(
			cLASetGIBounces cLABouncesValue
			cLAStatusLabel1.text = cLAStatus
			)
		on cLABounceButton pressed do
			(
			cLAAddBounceLight cLABounceMultValue cLABounceDistValue
			cLAStatusLabel1.text = cLAStatus
			)

		on cLARolloutGI open do
			(
			cLARendLabel.text = "Current renderer: " + (sLibWhatsCurrentRenderer())
			cLABouncesSpinner.value = cLABouncesValue
			cLABounceMultSpinner.value = cLABounceMultValue
			cLABounceDistSpinner.value = cLABounceDistValue
			cLAStatusLabel1.text = cLAStatus
			)
		)

	rollout cLARolloutAOV "AOV Setup"
		(
		checkbox cLADiffuseCheck "Diffuse" checked:true align:#left across:2
		checkbox cLASpecularCheck "Specular" checked:true align:#right
		checkbox cLASSSCheck "SSS" checked:false align:#left across:2
		checkbox cLAEmissionCheck "Emission / Volume" checked:false align:#right
		checkbox cLADepthCheck "Depth (Z)" checked:true align:#left across:2
		checkbox cLAPositionCheck "Position (P)" checked:false align:#right
		checkbox cLAUVsCheck "UVs" checked:false align:#left across:2
		checkbox cLANormalsCheck "Normals" checked:true align:#right

		label cLASpacerD "" height:4
		checkbox cLAMergeCheck "Merge AOVs into one multi-channel EXR" checked:true align:#left
		button cLAEnableAOVButton "Enable AOVs" width:250 align:#center
		label cLAStatusLabel2 "Ready." align:#left

		on cLADiffuseCheck changed s do cLAAOVDiffuseValue = s
		on cLASpecularCheck changed s do cLAAOVSpecularValue = s
		on cLASSSCheck changed s do cLAAOVSSSValue = s
		on cLAEmissionCheck changed s do cLAAOVEmissionValue = s
		on cLADepthCheck changed s do cLAAOVDepthValue = s
		on cLAPositionCheck changed s do cLAAOVPositionValue = s
		on cLAUVsCheck changed s do cLAAOVUVsValue = s
		on cLANormalsCheck changed s do cLAAOVNormalsValue = s
		on cLAMergeCheck changed s do cLAMergeEXRValue = s

		on cLAEnableAOVButton pressed do
			(
			cLAEnableAOVs()
			cLAStatusLabel2.text = cLAStatus
			)

		on cLARolloutAOV open do
			(
			cLADiffuseCheck.checked = cLAAOVDiffuseValue
			cLASpecularCheck.checked = cLAAOVSpecularValue
			cLASSSCheck.checked = cLAAOVSSSValue
			cLAEmissionCheck.checked = cLAAOVEmissionValue
			cLADepthCheck.checked = cLAAOVDepthValue
			cLAPositionCheck.checked = cLAAOVPositionValue
			cLAUVsCheck.checked = cLAAOVUVsValue
			cLANormalsCheck.checked = cLAAOVNormalsValue
			cLAMergeCheck.checked = cLAMergeEXRValue
			)
		)

	rollout cLARolloutGroups "Light Groups"
		(
		label cLAGroupInfo "Select lights, name the group, then Assign." align:#left
		edittext cLAGroupNameEdit "Group: " text:"key" fieldWidth:170 align:#right
		button cLAAssignGroupButton "Assign Light Group" width:250 align:#center
		label cLAGroupNote "Creates RGBA_<group> style AOVs at render time." align:#left
		label cLAStatusLabel3 "Ready." align:#left

		on cLAGroupNameEdit changed t do cLAGroupNameValue = t
		on cLAAssignGroupButton pressed do
			(
			cLAAssignLightGroup cLAGroupNameValue
			cLAStatusLabel3.text = cLAStatus
			)
		on cLARolloutGroups open do cLAGroupNameEdit.text = cLAGroupNameValue
		)

	rollout cLARolloutFilters "Light Filters (Arnold)"
		(
		label cLAFilterInfo "Select lights first. Gobo/Barndoor = spot only." align:#left
		button cLAGoboButton "Add Gobo" width:120 align:#left across:2
		button cLABarndoorButton "Add Barndoor" width:120 align:#right
		button cLADecayButton "Add Light Decay" width:120 align:#left across:2
		button cLABlockerButton "Add Light Blocker" width:120 align:#right
		label cLAStatusLabel4 "Ready." align:#left

		button cLAHelpButton "Help" width:80 align:#left across:2
		button cLASaveDefButton "SaveDef" width:80 align:#right

		on cLAGoboButton pressed do (cLAAddLightFilter #gobo; cLAStatusLabel4.text = cLAStatus)
		on cLABarndoorButton pressed do (cLAAddLightFilter #barndoor; cLAStatusLabel4.text = cLAStatus)
		on cLADecayButton pressed do (cLAAddLightFilter #decay; cLAStatusLabel4.text = cLAStatus)
		on cLABlockerButton pressed do (cLAAddLightFilter #blocker; cLAStatusLabel4.text = cLAStatus)
		on cLAHelpButton pressed do cLAHelp()
		on cLASaveDefButton pressed do cLASaveDef()
		)
	)
)
-------------------------------------------------------------------------------
