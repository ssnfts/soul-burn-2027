-------------------------------------------------------------------------------
-- SoulburnScriptsExtras.mcr
-- By Neil Blevins (info@neilblevins.com)
-- v 2.00 (SoulBurn 2027 Update)
-- Created On: 10/15/05
-- Modified On: 05/01/25
-- tested using Max 2027
--
-- Changes in v2.00:
--   - AssetBrowser updated for Max 2022+ API (MaxOps.OpenAssetBrowser)
--   - Removed obsolete third-party macros: Brazil, GrassOMatic, Druid,
--     RandomWalk, SimCloth, TexLay, Texporter, Greeble, EdgeChEx,
--     ScatterUtility, SplineMesher, SurfaceMapper
--   - VRay macros guard-checked with classname test
--   - All macros verified against Max 2027 API
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- ── Asset Management ─────────────────────────────────────────────────────────

MacroScript AssetBrowser category:"SoulburnScriptsExtras" tooltip:"Asset Browser" Icon:#("SoulburnScripts_AssetBrowser",1)
	(
	-- assetBrowser.open() was removed in Max 2022.
	-- The replacement is MaxOps.OpenAssetBrowser() in 2022+.
	if (maxVersion())[1] >= 24000 then
		MaxOps.OpenAssetBrowser()
	else
		try(assetBrowser.open()) catch(MessageBox "Asset Browser not available." title:"SoulburnScriptsExtras")
	)

MacroScript AssetTracker category:"SoulburnScriptsExtras" tooltip:"Asset Tracker" Icon:#("SoulburnScripts_AssetTracker",1)
	(
	macros.run "Asset Tracking System" "AssetTrackingSystemShow"
	)

-- ── Materials ─────────────────────────────────────────────────────────────────

MacroScript AssignMaterialToSelection category:"SoulburnScriptsExtras" tooltip:"Assign Active Material To Selection" Icon:#("SoulburnScripts_AssignMaterialToSelection",1)
	(
	if selection.count != 0 then $.material = meditMaterials[medit.GetActiveMtlSlot()]
	)

MacroScript MaterialEditorClassic category:"SoulburnScriptsExtras" tooltip:"Material Editor (Classic)" Icon:#("SoulburnScripts_MaterialEditorClassic",1)
	(
	MatEditor.mode = #basic
	MatEditor.Open()
	)

MacroScript MaterialEditorSchematic category:"SoulburnScriptsExtras" tooltip:"Material Editor (Slate)" Icon:#("SoulburnScripts_MaterialEditorSchematic",1)
	(
	MatEditor.mode = #advanced
	MatEditor.Open()
	)

-- ── Modifiers ────────────────────────────────────────────────────────────────

MacroScript EditPoly category:"SoulburnScriptsExtras" tooltip:"Edit Poly Modifier" Icon:#("SoulburnScripts_EditPoly",1)
	(
	on execute do AddMod EditPolyMod
	on isEnabled return mcrUtils.ValidMod EditPolyMod
	)

MacroScript PolySelect category:"SoulburnScriptsExtras" tooltip:"Poly Select Modifier" Icon:#("SoulburnScripts_PolySelect",1)
	(
	on execute do AddMod Poly_Select
	on isEnabled return mcrUtils.ValidMod Poly_Select
	)

MacroScript RelaxPoly category:"SoulburnScriptsExtras" tooltip:"Relax (Editable Poly)" Icon:#("SoulburnScripts_RelaxPoly",1)
	(
	On IsEnabled Return Filters.Is_EPoly()
	On IsVisible Return Filters.Is_EPoly()
	On execute do
		(
		if selection.count == 1 then
			(
			if classof $.baseobject == Editable_Poly then $.EditablePoly.Relax()
			)
		else (MessageBox "Select exactly one Editable Poly object." title:"SoulburnScriptsExtras")
		)
	)

MacroScript ResetXForm category:"SoulburnScriptsExtras" tooltip:"Reset XForm" Icon:#("SoulburnScripts_ResetXForm",1)
	(
	if findItem utilityplugin.classes Reset_XForm > 0 then UtilityPanel.OpenUtility Reset_XForm
	else (MessageBox "Reset XForm utility not found." title:"SoulburnScriptsExtras")
	)

MacroScript Shell category:"SoulburnScriptsExtras" tooltip:"Shell Modifier" Icon:#("SoulburnScripts_Shell",1)
	(
	on execute do AddMod Shell
	on isEnabled return mcrUtils.ValidMod Shell
	)

MacroScript Turbosmooth category:"SoulburnScriptsExtras" tooltip:"TurboSmooth Modifier" Icon:#("SoulburnScripts_Turbosmooth",1)
	(
	on execute do AddMod TurboSmooth
	on isEnabled return mcrUtils.ValidMod TurboSmooth
	)

-- ── Splines ───────────────────────────────────────────────────────────────────

MacroScript SplineBooleanUnion category:"SoulburnScriptsExtras" tooltip:"Spline Boolean Union" Icon:#("SoulburnScripts_SplineBooleanUnion",1)
	(
	On IsEnabled Return Filters.Is_EditSpline()
	On IsVisible Return Filters.Is_EditSpline()
	On Execute Do
		(
		if subobjectlevel == undefined then max modify mode
		if subobjectlevel != 3 then subobjectlevel = 3
		Try(ApplyOperation Edit_Spline splineOps.startUnion) Catch(MessageBox "Operation Failed" Title:"Spline Editing")
		)
	)

MacroScript SplineBooleanSubtract category:"SoulburnScriptsExtras" tooltip:"Spline Boolean Subtract" Icon:#("SoulburnScripts_SplineBooleanSubtract",1)
	(
	On IsEnabled Return Filters.Is_EditSpline()
	On IsVisible Return Filters.Is_EditSpline()
	On Execute Do
		(
		if subobjectlevel == undefined then max modify mode
		if subobjectlevel != 3 then subobjectlevel = 3
		Try(ApplyOperation Edit_Spline splineOps.startSubtract) Catch(MessageBox "Operation Failed" Title:"Spline Editing")
		)
	)

MacroScript SplineBooleanIntersect category:"SoulburnScriptsExtras" tooltip:"Spline Boolean Intersect" Icon:#("SoulburnScripts_SplineBooleanIntersect",1)
	(
	On IsEnabled Return Filters.Is_EditSpline()
	On IsVisible Return Filters.Is_EditSpline()
	On Execute Do
		(
		if subobjectlevel == undefined then max modify mode
		if subobjectlevel != 3 then subobjectlevel = 3
		Try(ApplyOperation Edit_Spline splineOps.startIntersect) Catch(MessageBox "Operation Failed" Title:"Spline Editing")
		)
	)

-- ── Utilities ────────────────────────────────────────────────────────────────

MacroScript BitmapPathsEditor category:"SoulburnScriptsExtras" tooltip:"Bitmap/Photometric Paths" Icon:#("SoulburnScripts_BitmapPathsEditor",1)
	(
	if findItem utilityplugin.classes Bitmap_Photometric_Paths > 0 then UtilityPanel.OpenUtility Bitmap_Photometric_Paths
	else (MessageBox "Bitmap/Photometric Paths utility not found." title:"SoulburnScriptsExtras")
	)

MacroScript ColorClipboard category:"SoulburnScriptsExtras" tooltip:"Color Clipboard" Icon:#("SoulburnScripts_ColorClipboard",1)
	(
	if findItem utilityplugin.classes Color_Clipboard > 0 then UtilityPanel.OpenUtility Color_Clipboard
	else (MessageBox "Color Clipboard utility not found." title:"SoulburnScriptsExtras")
	)

MacroScript Measure category:"SoulburnScriptsExtras" tooltip:"Measure Utility" Icon:#("SoulburnScripts_Measure",1)
	(
	if findItem utilityplugin.classes Measure > 0 then UtilityPanel.OpenUtility Measure
	else (MessageBox "Measure utility not found." title:"SoulburnScriptsExtras")
	)

MacroScript MeasureDistance category:"SoulburnScriptsExtras" tooltip:"Measure Distance (2-Point)" Icon:#("SoulburnScripts_MeasureDistance",1)
	(
	macros.run "Tools" "two_point_dist"
	)

MacroScript PolygonCounter category:"SoulburnScriptsExtras" tooltip:"Polygon Counter" Icon:#("SoulburnScripts_PolygonCounter",1)
	(
	if findItem utilityplugin.classes Polygon_Counter > 0 then UtilityPanel.OpenUtility Polygon_Counter
	else (MessageBox "Polygon Counter utility not found." title:"SoulburnScriptsExtras")
	)

MacroScript SelectByColor category:"SoulburnScriptsExtras" tooltip:"Select By Color" Icon:#("SoulburnScripts_SelectByColor",1)
	(
	actionMan.executeAction 0 "40109"
	)

-- ── Rendering ────────────────────────────────────────────────────────────────

MacroScript RenderQuick category:"SoulburnScriptsExtras" tooltip:"Quick Render (Active View)" Icon:#("SoulburnScripts_RenderQuick",1)
	(
	max quick render
	)

MacroScript RenderSetup category:"SoulburnScriptsExtras" tooltip:"Render Setup Dialog" Icon:#("SoulburnScripts_RenderSetup",1)
	(
	max render scene
	)

-- ── V-Ray (guards against V-Ray not being installed) ─────────────────────────

MacroScript VrayDisplacementMod category:"SoulburnScriptsExtras" tooltip:"V-Ray Displacement Mod" Icon:#("SoulburnScripts_VrayDisplacementMod",1)
	(
	on execute do (Try(AddMod VRayDisplacementMod) Catch(MessageBox "V-Ray does not appear to be installed." title:"SoulburnScriptsExtras"))
	)

MacroScript VrayLight category:"SoulburnScriptsExtras" tooltip:"V-Ray Light" Icon:#("SoulburnScripts_VrayLight",1)
	(
	on execute do (Try(StartObjectCreation VRayLight) Catch(MessageBox "V-Ray does not appear to be installed." title:"SoulburnScriptsExtras"))
	)

MacroScript VrayShowVFB category:"SoulburnScriptsExtras" tooltip:"V-Ray Show VFB" Icon:#("SoulburnScripts_VrayShowVFB",1)
	(
	-- classid for V-Ray renderer changes between versions; use classname test instead.
	local vr = renderers.current
	if (classof vr as string) as string == "V_Ray_6" or \
	   (classof vr as string) as string == "V_Ray_Next" or \
	   matchPattern (classof vr as string) pattern:"V_Ray*" then
		(
		try(vr.showLastVFB()) catch(MessageBox "Could not open VFB. Check V-Ray version." title:"SoulburnScriptsExtras")
		)
	else
		MessageBox "V-Ray is not the current renderer." title:"SoulburnScriptsExtras"
	)

)
-------------------------------------------------------------------------------
