-------------------------------------------------------------------------------
-- splinePainter.ms
-- By Neil Blevins (info@neilblevins.com)
-- v 2.00
-- Created On: 03/23/08
-- Modified On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- This script lets you paint splines on the surface of another piece of 
-- geometry.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Make a plane with many segments, apply a noise modifier to make it hilly. 
-- Run the UI version of the script. Select the plane, click the "Add Selection 
-- To Paint On List" Button. The plane is added to the list. Now click the 
-- "Paint" botton", and start painting with the mouse on the plane, you'll see
-- a spline forming. To turn off, click the Paint button again. To delete your 
-- last painted splines, undo or hit the Delete button.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Revision History:
--
-- v 1.01 Fixed issue that would turn the paint button off even though you could
-- still paint. Added Surface Offset Value, to place the spline a specified 
-- distance away from the surface. Added a way to rename the splines.
--
-- v 1.02 Added normalize feature to get smoother spacing between spline verts
-- (although too much space will reduce spline detail).
--
-- v 1.03 Replaced the Close button with a Help button. Use the X button to 
-- Close the Floater.
--
-- v 1.04 Added ability to close the spline after creation.
--
-- v 1.05 Fixed a bug that would crash the script if you tried loading some 
-- presets.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- 1) There's a known max8 crash bug with the painter system and the undo 
-- system. So if you're using max8 and this script, be careful using undo. 
-- The problem does not exist in max 2008.
-- 2) This script misbehaves if used on scenes that have duplicate object 
-- names. If the script refuses to paint even though you have everything setup 
-- correctly, check to see if any objects in your scene have duplicate names. 
-- Fixing the names will allow the script to function properly.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global splinePainterDefaults
global splinePainterUI

global sPACloseOpenUI

global sPAstartStroke
global sPApaintStroke
global sPAendStroke
global sPAcancelStroke
global sPAsystemEnd

global sPAHelp
global sPALoadDef
global sPASaveDef

global sPADefineUI
global sPADefineEMUI
global sPARollout
global sPAEMRollout
global sPAFloater

-- Includes

include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables

global sPASpline
global sPANewS
global sPAThick

global sPABrushSizeValue = 10
global sPASplineDetailValue = 100
global sPANormalizeValue = false
global sPANormalizeFactorValue = 20.0
global sPAStepsValue = 2
global sPASurfaceOffsetValue = 0.0
global sPAPrefixValue = "sPA_Line"
global sPACloseValue = false
global sPARenderableValue = false
global sPAMappingValue = false
global sPAThicknessValue = 1 
global sPAMinThicknessValue = 1.0
global sPAMaxThicknessValue = 2.0
global sPASidesValue = 6
global sPAPlaceValue = 1

global sPAPaintOnList = #()
global sPALastSplines = #()

sPAPosValue = [85,90]

-- Functions

fn splinePainterDefaults = 
	(
	sPALoadDef()
	)

fn splinePainterUI = 
	(
	sPALoadDef()
	sPACloseOpenUI sPAPosValue
	)
	
fn sPACloseOpenUI pos = 
	(
	if sPAFloater != undefined then CloseRolloutFloater sPAFloater
	sPADefineUI()
	sPAFloater = newRolloutFloater "splinePainter v1.05" 210 629 pos.x pos.y
	addRollout sPARollout sPAFloater
	)

-- v2.00: Paint stroke helpers rewritten for MouseTrack (thePainterInterface removed in Max 2020)

fn sPABeginNewSpline =
	(
	sPASpline = line pos:[0,0,0]
	sPASpline.name = uniquename sPAPrefixValue
	sPASpline.baseobject.renderable = sPARenderableValue
	sPASpline.baseobject.DisplayRenderMesh = sPARenderableValue
	sPASpline.baseobject.mapCoords = sPAMappingValue
	if sPAThicknessValue == 1 then
		(
		sPAThick = random sPAMinThicknessValue sPAMaxThicknessValue
		sPASpline.baseobject.render_thickness = sPAThick
		)
	else sPASpline.baseobject.render_thickness = sPABrushSizeValue
	sPASpline.baseobject.render_sides = sPASidesValue
	sPASpline.baseobject.steps = sPAStepsValue
	sPANewS = addnewspline sPASpline
	)

fn sPAFinishSpline =
	(
	if sPASpline != undefined then
		(
		if sPACloseValue == true then close sPASpline 1
		updateshape sPASpline
		if sPANormalizeValue == true then
			(
			pathLength = curveLength sPASpline 1
			nMod = Normalize_Spl()
			addmodifier sPASpline nMod
			nMod.length = pathLength / sPANormalizeFactorValue
			)
		append sPALastSplines sPASpline
		)
	)

fn sPARaycastToSurface screenPos =
	(
	local hitPos = undefined
	local paintObjs = for n in sPAPaintOnList where (getNodeByName n) != undefined collect (getNodeByName n)
	if paintObjs.count == 0 then return undefined
	local theRay = mapScreenToWorldRay screenPos
	local bestT = 1e30
	for obj in paintObjs do
		(
		try
			(
			local hit = intersectRay obj theRay
			if hit != undefined then
				(
				local t = distance theRay.pos hit.pos
				if t < bestT then
					(
					bestT = t
					local dist = sPASurfaceOffsetValue
					if sPAPlaceValue == 2 then
						(
						if sPAThicknessValue == 1 then dist += (sPAThick / 2.0)
						else dist += (sPABrushSizeValue / 2.0)
						)
					hitPos = hit.pos + (normalize(hit.dir) * dist)
					)
				)
			) catch ()
		)
	return hitPos
	)

fn sPAMouseTrackCallback msg clickpos dir which shift ctrl alt =
	(
	case msg of
		(
		#mousePoint:
			(
			if which == 1 then
				(
				sPABeginNewSpline()
				local hp = sPARaycastToSurface clickpos
				if hp != undefined then addknot sPASpline sPANewS #smooth #curve hp
				)
			else if which == -1 then
				(
				sPAFinishSpline()
				sPASpline = undefined
				)
			return #continue
			)
		#mouseMove:
			(
			if sPASpline != undefined then
				(
				if ((random 1 99) + (sPASplineDetailValue - 50)) > 50 then
					(
					local hp = sPARaycastToSurface clickpos
					if hp != undefined then addknot sPASpline sPANewS #smooth #curve hp
					)
				)
			return #continue
			)
		#mouseAbort:
			(
			if sPASpline != undefined then
				(
				delete sPASpline
				sPASpline = undefined
				)
			return #abort
			)
		)
	return #continue
	)
	
fn sPAHelp = 
	(
	sLibSSPrintHelp "splinePainter"
	)
	
fn sPALoadDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	sPAInputFilename = presetDir + "splinePainter.ini"
	if (sLibFileExist sPAInputFilename == true) then
		(
		sPABrushSizeValue = sLibGetINIInteger sPAInputFilename "splinePainter" "sPABrushSizeValue" 10
		sPASplineDetailValue = sLibGetINIInteger sPAInputFilename "splinePainter" "sPASplineDetailValue" 100
		sPANormalizeValue = sLibGetINIBoolean sPAInputFilename "splinePainter" "sPANormalizeValue" false
		sPANormalizeFactorValue = sLibGetINIFloat sPAInputFilename "splinePainter" "sPANormalizeFactorValue" 20.0
		sPAStepsValue = sLibGetINIInteger sPAInputFilename "splinePainter" "sPAStepsValue" 2
		sPASurfaceOffsetValue = sLibGetINIFloat sPAInputFilename "splinePainter" "sPASurfaceOffsetValue" 0.0
		sPAPrefixValue = sLibGetINIString sPAInputFilename "splinePainter" "sPAPrefixValue" "sPA_Line"
		sPACloseValue = sLibGetINIBoolean sPAInputFilename "splinePainter" "sPACloseValue" false
		sPARenderableValue = sLibGetINIBoolean sPAInputFilename "splinePainter" "sPARenderableValue" false
		sPAMappingValue = sLibGetINIBoolean sPAInputFilename "splinePainter" "sPAMappingValue" false
		sPAThicknessValue = sLibGetINIInteger sPAInputFilename "splinePainter" "sPAThicknessValue" 1
		sPAMinThicknessValue = sLibGetINIFloat sPAInputFilename "splinePainter" "sPAMinThicknessValue" 1.0
		sPAMaxThicknessValue = sLibGetINIFloat sPAInputFilename "splinePainter" "sPAMaxThicknessValue" 2.0
		sPASidesValue = sLibGetINIInteger sPAInputFilename "splinePainter" "sPASidesValue" 6
		sPAPlaceValue = sLibGetINIInteger sPAInputFilename "splinePainter" "sPAPlaceValue" 1
		sPAPosValue = sLibGetINIPoint2 sPAInputFilename "splinePainter" "sPAPosValue" ([85,90])
		
		)
	else
		(
		sPABrushSizeValue = 10
		sPASplineDetailValue = 100
		sPANormalizeValue = false
		sPANormalizeFactorValue = 20.0
		sPAStepsValue = 2
		sPASurfaceOffsetValue = 0.0
		sPAPrefixValue = "sPA_Line"
		sPACloseValue = false
		sPARenderableValue = false
		sPAMappingValue = false
		sPAThicknessValue = 1 
		sPAMinThicknessValue = 1.0
		sPAMaxThicknessValue = 2.0
		sPASidesValue = 6
		sPAPlaceValue = 1
		sPAPosValue = [85,90]
		)
	)
	
fn sPASaveDef = 
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	sPAOutputFilename = presetDir + "splinePainter.ini"
	if (sLibFileExist sPAOutputFilename == true) then deleteFile sPAOutputFilename
	setINISetting sPAOutputFilename "splinePainter" "sPABrushSizeValue" (sPABrushSizeValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPASplineDetailValue" (sPASplineDetailValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPANormalizeValue" (sPANormalizeValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPANormalizeFactorValue" (sPANormalizeFactorValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAStepsValue" (sPAStepsValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPASurfaceOffsetValue" (sPASurfaceOffsetValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAPrefixValue" (sPAPrefixValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPACloseValue" (sPACloseValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPARenderableValue" (sPARenderableValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAMappingValue" (sPAMappingValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAThicknessValue" (sPAThicknessValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAMinThicknessValue" (sPAMinThicknessValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAMaxThicknessValue" (sPAMaxThicknessValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPASidesValue" (sPASidesValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAPlaceValue" (sPAPlaceValue as string)
	setINISetting sPAOutputFilename "splinePainter" "sPAPosValue" (sPAFloater.pos as string)
	)

-- UI

fn sPADefineUI = 
	(
	rollout sPARollout "splinePainter"
		(
		group "Paint On"
		(
		button sPAPaintOnButton "Add Sel To Paint On List" toolTip:"Add Selection To Paint On List" width:153 align:#left across:2
		button sPAPaintOnDelButton "-" toolTip:"Delete Choosen Object From Paint On List" width:15 align:#right
		listbox sPAPaintOnListbox "Paint On List:" items:sPAPaintOnList height:6
		)

		group "Options"
		(
		spinner sPABrushSizeSpinner "Brush Size: " range:[0,9999999,sPABrushSizeValue] fieldWidth:40 type:#float align:#right
		spinner sPASplineDetailSpinner "Spline Detail: " range:[0,100,sPASplineDetailValue] fieldWidth:40 type:#float align:#right
		checkbox sPANormalizeCheckbox "Normalize?" checked:sPANormalizeValue across:2
		spinner sPANormalizeFactorSpinner "Factor: " range:[1,999999,sPANormalizeFactorValue] type:#float fieldWidth:35 offset:[0,1]
		spinner sPAStepsSpinner "Spline Steps: " range:[0,100,sPAStepsValue] fieldWidth:40 type:#integer align:#right
		spinner sPASurfaceOffsetSpinner "Surface Offset: " range:[-9999999,9999999,sPASurfaceOffsetValue] fieldWidth:40 type:#float align:#right
		edittext sPAPrefixEditText "Prefix:" fieldWidth:110 text:sPAPrefixValue align:#right
		button sPASelectObjsButton "Select" width:80 align:#center toolTip:"Select Previous Painted Objects" across:2
		button sPADeleteObjsButton "Delete" width:80 align:#center toolTip:"Delete Previous Painted Objects"
		checkbox sPACloseCheckbox "Close?" checked:sPACloseValue align:#right
		)
		
		group "Renderable"
		(
		checkbox sPARenderableCheckbox "Renderable?" checked:sPARenderableValue align:#right
		checkbox sPAMappingCheckbox "Generate Mapping Coords?" checked:sPAMappingValue align:#right
		dropdownlist sPAThicknessDropdown "" items:#("Random Thickness", "Thickness Based On Brush Size") width:170 selection:sPAThicknessValue align:#right
		spinner sPAMinThicknessSpinner "Min Thickness: " range:[0,9999999,sPAMinThicknessValue] fieldWidth:40 type:#float align:#right
		spinner sPAMaxThicknessSpinner "Max Thickness: " range:[0,9999999,sPAMaxThicknessValue] fieldWidth:40 type:#float align:#right
		spinner sPASidesSpinner "Sides: " range:[3,100,sPASidesValue] fieldWidth:40 type:#integer align:#right
		dropdownlist sPAPlaceDropdown "" items:#("Place Spline On Surface", "Place Surface On Surface") width:170 selection:sPAPlaceValue align:#right
		)
		
		checkbutton sPAOnOrOffButton "Paint" checked:false align:#center width:170

		on sPAPaintOnButton pressed do 
			(
			sPAPaintOnList = #()
			error = false
			for i in selection do
				(
				if (sLibGeometryFilter i) == false then error = true
				else append sPAPaintOnList i.name
				)
			if error == true then (MessageBox "One of your objects to be painted on is not a piece of geometry and was removed from your list." title:"splinePainter")
			curPos = sPAFloater.pos
			curOn = sPAOnOrOffButton.checked
			sPACloseOpenUI curPos
			if curOn == true then (sPAOnOrOffButton.text = "Stop Paint";sPAOnOrOffButton.checked = true)
			)
		on sPAPaintOnDelButton pressed do 
			(
			if sPAPaintOnList.count != 0 then 
				(
				deleteItem sPAPaintOnList sPAPaintOnListbox.selection
				curPos = sPAFloater.pos
				curOn = sPAOnOrOffButton.checked
				sPACloseOpenUI curPos
				if curOn == true then (sPAOnOrOffButton.text = "Stop Paint";sPAOnOrOffButton.checked = true)
				)
			)

		on sPABrushSizeSpinner changed val do sPABrushSizeValue = val
		on sPASplineDetailSpinner changed val do sPASplineDetailValue = val
		on sPANormalizeCheckbox changed state do 
			(
			sPANormalizeValue = state
			sPANormalizeFactorSpinner.enabled = state
			)
		on sPANormalizeFactorSpinner changed val do sPANormalizeFactorValue = val
		on sPAStepsSpinner changed val do sPAStepsValue = val
		on sPASurfaceOffsetSpinner changed val do sPASurfaceOffsetValue = val
		on sPAPrefixEditText changed text do sPAPrefixValue = sPAPrefixEditText.text
		on sPACloseCheckbox changed state do sPACloseValue = state
		
		on sPASelectObjsButton pressed do 
			(
			undo "splinePainter" on
				(
				sPALastSplinesWhoExist = #()
				myerror = false
				for o in sPALastSplines do
					(
					if (IsValidNode o) == true then append sPALastSplinesWhoExist o
					else myerror = true 
					)
				if myerror == true then (MessageBox "At least one spline no longer exists. Selecting any splines that still exist." title:"splinePainter")
				if sPALastSplinesWhoExist.count != 0 then (select sPALastSplinesWhoExist)
				)
			)
		on sPADeleteObjsButton pressed do 
			(
			undo "splinePainter" on
				(
				sPALastSplinesWhoExist = #()
				myerror = false
				for o in sPALastSplines do
					(
					if (IsValidNode o) == true then append sPALastSplinesWhoExist o
					else myerror = true 
					)
				if myerror == true then (MessageBox "At least one spline no longer exists. Selecting any splines that still exist." title:"splinePainter")
				for o in sPALastSplinesWhoExist do delete o
				sPALastSplines = #()
				sPALastSplinesWhoExist = #()
				)
			)

		on sPARenderableCheckbox changed state do 
			(
			sPARenderableValue = state		
			curPos = sPAFloater.pos
			curOn = sPAOnOrOffButton.checked
			sPACloseOpenUI curPos
			if curOn == true then (sPAOnOrOffButton.text = "Stop Paint";sPAOnOrOffButton.checked = true)
			)
		on sPAMappingCheckbox changed state do sPAMappingValue = state	
		on sPAThicknessDropdown selected i do
			(
			sPAThicknessValue = i
			curPos = sPAFloater.pos
			curOn = sPAOnOrOffButton.checked
			sPACloseOpenUI curPos
			if curOn == true then (sPAOnOrOffButton.text = "Stop Paint";sPAOnOrOffButton.checked = true)
			)
		on sPAMinThicknessSpinner changed val do sPAMinThicknessValue = val
		on sPAMaxThicknessSpinner changed val do sPAMaxThicknessValue = val
		on sPASidesSpinner changed val do sPASidesValue = val
		on sPAPlaceDropdown selected i do
			(
			sPAPlaceValue = i
			curPos = sPAFloater.pos
			curOn = sPAOnOrOffButton.checked
			sPACloseOpenUI curPos
			if curOn == true then (sPAOnOrOffButton.text = "Stop Paint";sPAOnOrOffButton.checked = true)
			)
	
		on sPAOnOrOffButton changed state do
			(
			-- v2.00: Use MouseTrack instead of removed thePainterInterface (Max 2020+)
			if state == false then
				(
				sPAOnOrOffButton.text = "Paint"
				)
			else
				(
				if sPAPaintOnList.count == 0 then
					(
					MessageBox "Please add objects to the 'Paint On' List" title:"splinePainter"
					sPAOnOrOffButton.checked = false
					)
				else
					(
					sPAOnOrOffButton.text = "Stop Paint (Right-click)"
					sPASpline = undefined
					MouseTrack trackCallback:sPAMouseTrackCallback cursor:#crossHair
					sPAOnOrOffButton.text = "Paint"
					sPAOnOrOffButton.checked = false
					)
				)
			)
			
		button sPAHelpButton "Help" width:50 toolTip:"Help" pos:[45,570]
		on sPAHelpButton pressed do sPAHelp()
		button sPASaveDefButton "SaveDef" width:50 toolTip:"Save Current Settings as Default" pos:[100,570]
		on sPASaveDefButton pressed do sPASaveDef()
		
		on sPARollout open do
			(
			if sPARenderableValue == false then
				(
				sPAPlaceValue = 1
				sPAPlaceDropdown.selection = 1
				sPAPlaceDropdown.enabled = false
				sPAMappingCheckbox.enabled = false
				sPAThicknessDropdown.enabled = false
				sPAMaxThicknessSpinner.enabled = false
				sPAMinThicknessSpinner.enabled = false
				sPASidesSpinner.enabled = false
				)
			if sPAThicknessValue == 2 then (sPAMinThicknessSpinner.enabled = false;sPAMaxThicknessSpinner.enabled = false)
			if sPANormalizeValue == true then sPANormalizeFactorSpinner.enabled = true else sPANormalizeFactorSpinner.enabled = false
			)
		)
	)
)
-------------------------------------------------------------------------------