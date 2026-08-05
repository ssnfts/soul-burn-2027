-------------------------------------------------------------------------------
-- SoulburnScripts.mcr
-- By Neil Blevins (info@neilblevins.com)
-- v 2.00 (SoulBurn 2027 Update)
-- Created On: 04/08/05
-- Modified On: 05/01/25
-- tested using Max 2027
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
MacroScript aligner category:"SoulburnScripts" tooltip:"aligner" Icon:#("SoulburnScripts_aligner",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/aligner.ms"
	on execute do alignerDefaults()
	on Altexecute type do alignerUI()
	)
	
MacroScript alignerUI category:"SoulburnScripts" tooltip:"alignerUI" Icon:#("SoulburnScripts_alignerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/aligner.ms"
	alignerUI()
	)

MacroScript alignerSelectModePosition category:"SoulburnScripts" tooltip:"alignerSelectModePosition" Icon:#("SoulburnScripts_alignerSelectModePosition",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/aligner.ms"
	on execute do aligner 1 true true true 1 1 false false false false false false
	on Altexecute type do alignerUI()
	)
	
MacroScript alignerSelectModeRotation category:"SoulburnScripts" tooltip:"alignerSelectModeRotation" Icon:#("SoulburnScripts_alignerSelectModeRotation",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/aligner.ms"
	on execute do aligner 1 false false false 1 1 true true true false false false
	on Altexecute type do alignerUI()
	)
	
MacroScript alignerSelectModeScale category:"SoulburnScripts" tooltip:"alignerSelectModeScale" Icon:#("SoulburnScripts_alignerSelectModeScale",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/aligner.ms"
	on execute do aligner 1 false false false 1 1 false false false true true true
	on Altexecute type do alignerUI()
	)
	
MacroScript alignViewportToFace category:"SoulburnScripts" tooltip:"alignViewportToFace" Icon:#("SoulburnScripts_alignViewportToFace",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/alignViewportToFace.ms"
	on execute do alignViewportToFaceDefaults()
	on Altexecute type do alignViewportToFaceUI()
	)
	
MacroScript alignViewportToFaceUI category:"SoulburnScripts" tooltip:"alignViewportToFaceUI" Icon:#("SoulburnScripts_alignViewportToFaceUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/alignViewportToFace.ms"
	alignViewportToFaceUI()
	)

MacroScript bitmapCollector category:"SoulburnScripts" tooltip:"bitmapCollector" Icon:#("SoulburnScripts_bitmapCollector",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/bitmapCollector.ms"
	on execute do bitmapCollectorDefaults()
	on Altexecute type do bitmapCollectorUI()
	)
	
MacroScript bitmapCollectorUI category:"SoulburnScripts" tooltip:"bitmapCollectorUI" Icon:#("SoulburnScripts_bitmapCollectorUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/bitmapCollector.ms"
	bitmapCollectorUI()
	)
	
MacroScript blendedBoxMapMaker category:"SoulburnScripts" tooltip:"blendedBoxMapMaker" Icon:#("SoulburnScripts_blendedBoxMapMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedBoxMapMaker.ms"
	on execute do blendedBoxMapMakerDefaults()
	on Altexecute type do blendedBoxMapMakerUI()
	)
	
MacroScript blendedBoxMapMakerUI category:"SoulburnScripts" tooltip:"blendedBoxMapMakerUI" Icon:#("SoulburnScripts_blendedBoxMapMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedBoxMapMaker.ms"
	blendedBoxMapMakerUI()
	)
	
MacroScript blendedBoxMapManager category:"SoulburnScripts" tooltip:"blendedBoxMapManager" Icon:#("SoulburnScripts_blendedBoxMapManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedBoxMapManager.ms"
	on execute do blendedBoxMapManagerDefaults()
	on Altexecute type do blendedBoxMapManagerUI()
	)
	
MacroScript blendedBoxMapManagerUI category:"SoulburnScripts" tooltip:"blendedBoxMapManagerUI" Icon:#("SoulburnScripts_blendedBoxMapManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedBoxMapManager.ms"
	blendedBoxMapManagerUI()
	)

MacroScript blendedCubeProjectionMaker category:"SoulburnScripts" tooltip:"blendedCubeProjectionMaker" Icon:#("SoulburnScripts_blendedCubeProjectionMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedCubeProjectionMaker.ms"
	on execute do blendedCubeProjectionMakerDefaults()
	on Altexecute type do blendedCubeProjectionMakerUI()
	)
	
MacroScript blendedCubeProjectionMakerUI category:"SoulburnScripts" tooltip:"blendedCubeProjectionMakerUI" Icon:#("SoulburnScripts_blendedCubeProjectionMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedCubeProjectionMaker.ms"
	blendedCubeProjectionMakerUI()
	)

MacroScript blendedCubeProjectionManager category:"SoulburnScripts" tooltip:"blendedCubeProjectionManager" Icon:#("SoulburnScripts_blendedCubeProjectionManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedCubeProjectionManager.ms"
	on execute do blendedCubeProjectionManagerDefaults()
	on Altexecute type do blendedCubeProjectionManagerUI()
	)
	
MacroScript blendedCubeProjectionManagerUI category:"SoulburnScripts" tooltip:"blendedCubeProjectionManagerUI" Icon:#("SoulburnScripts_blendedCubeProjectionManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/blendedCubeProjectionManager.ms"
	blendedCubeProjectionManagerUI()
	)

MacroScript cameraFromPerspView category:"SoulburnScripts" tooltip:"cameraFromPerspView" Icon:#("SoulburnScripts_cameraFromPerspView",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cameraFromPerspView.ms"
	on execute do cameraFromPerspViewDefaults()
	on Altexecute type do cameraFromPerspViewUI()
	)
	
MacroScript cameraFromPerspViewUI category:"SoulburnScripts" tooltip:"cameraFromPerspViewUI" Icon:#("SoulburnScripts_cameraFromPerspViewUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cameraFromPerspView.ms"
	cameraFromPerspViewUI()
	)
	
MacroScript cameraLensPackager category:"SoulburnScripts" tooltip:"cameraLensPackager" Icon:#("SoulburnScripts_cameraLensPackager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cameraLensPackager.ms"
	on execute do cameraLensPackagerDefaults()
	on Altexecute type do cameraLensPackagerUI()
	)
	
MacroScript cameraLensPackagerUI category:"SoulburnScripts" tooltip:"cameraLensPackagerUI" Icon:#("SoulburnScripts_cameraLensPackagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cameraLensPackager.ms"
	cameraLensPackagerUI()
	)

MacroScript cameraMapTemplateRenderer category:"SoulburnScripts" tooltip:"cameraMapTemplateRenderer" Icon:#("SoulburnScripts_cameraMapTemplateRenderer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cameraMapTemplateRenderer.ms"
	on execute do cameraMapTemplateRendererDefaults()
	on Altexecute type do cameraMapTemplateRendererUI()
	)
	
MacroScript cameraMapTemplateRendererUI category:"SoulburnScripts" tooltip:"cameraMapTemplateRendererUI" Icon:#("SoulburnScripts_cameraMapTemplateRendererUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cameraMapTemplateRenderer.ms"
	cameraMapTemplateRendererUI()
	)
	
MacroScript circleArrayMaker category:"SoulburnScripts" tooltip:"circleArrayMaker" Icon:#("SoulburnScripts_circleArrayMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/circleArrayMaker.ms"
	on execute do circleArrayMakerDefaults()
	on Altexecute type do circleArrayMakerUI()
	)
	
MacroScript circleArrayMakerUI category:"SoulburnScripts" tooltip:"circleArrayMakerUI" Icon:#("SoulburnScripts_circleArrayMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/circleArrayMaker.ms"
	circleArrayMakerUI()
	)

MacroScript curvatureMaker category:"SoulburnScripts" tooltip:"curvatureMaker" Icon:#("SoulburnScripts_curvatureMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/curvatureMaker.ms"
	on execute do curvatureMakerDefaults()
	on Altexecute type do curvatureMakerUI()
	)
	
MacroScript curvatureMakerUI category:"SoulburnScripts" tooltip:"curvatureMakerUI" Icon:#("SoulburnScripts_curvatureMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/curvatureMaker.ms"
	curvatureMakerUI()
	)
	
MacroScript curvatureManager category:"SoulburnScripts" tooltip:"curvatureManager" Icon:#("SoulburnScripts_curvatureManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/curvatureManager.ms"
	on execute do curvatureManagerDefaults()
	on Altexecute type do curvatureManagerUI()
	)
	
MacroScript curvatureManagerUI category:"SoulburnScripts" tooltip:"curvatureManagerUI" Icon:#("SoulburnScripts_curvatureManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/curvatureManager.ms"
	curvatureManagerUI()
	)

MacroScript customAttributeRemover category:"SoulburnScripts" tooltip:"customAttributeRemover" Icon:#("SoulburnScripts_customAttributeRemover",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/customAttributeRemover.ms"
	on execute do customAttributeRemoverDefaults()
	on Altexecute type do customAttributeRemoverUI()
	)
	
MacroScript customAttributeRemoverUI category:"SoulburnScripts" tooltip:"customAttributeRemoverUI" Icon:#("SoulburnScripts_customAttributeRemoverUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/customAttributeRemover.ms"
	customAttributeRemoverUI()
	)

MacroScript edgeDivider category:"SoulburnScripts" tooltip:"edgeDivider" Icon:#("SoulburnScripts_edgeDivider",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDividerDefaults()
	on Altexecute type do edgeDividerUI()
	)
	
MacroScript edgeDividerUI category:"SoulburnScripts" tooltip:"edgeDividerUI" Icon:#("SoulburnScripts_edgeDividerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/edgeDivider.ms"
	edgeDividerUI()
	)
	
MacroScript edgeDivider2 category:"SoulburnScripts" tooltip:"edgeDivider2" Icon:#("SoulburnScripts_edgeDivider2",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDivider 2
	on Altexecute type do edgeDividerUI()
	)

MacroScript edgeDivider3 category:"SoulburnScripts" tooltip:"edgeDivider3" Icon:#("SoulburnScripts_edgeDivider3",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDivider 3
	on Altexecute type do edgeDividerUI()
	)
	
MacroScript edgeDivider4 category:"SoulburnScripts" tooltip:"edgeDivider4" Icon:#("SoulburnScripts_edgeDivider4",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/edgeDivider.ms"
	on execute do edgeDivider 4
	on Altexecute type do edgeDividerUI()
	)

MacroScript edgeSelectByAngle category:"SoulburnScripts" tooltip:"edgeSelectByAngle" Icon:#("SoulburnScripts_edgeSelectByAngle",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/edgeSelectByAngle.ms"
	on execute do edgeSelectByAngleDefaults()
	on Altexecute type do edgeSelectByAngleUI()
	)
	
MacroScript edgeSelectByAngleUI category:"SoulburnScripts" tooltip:"edgeSelectByAngleUI" Icon:#("SoulburnScripts_edgeSelectByAngleUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/edgeSelectByAngle.ms"
	edgeSelectByAngleUI()
	)

MacroScript elementSelectByFace category:"SoulburnScripts" tooltip:"elementSelectByFace" Icon:#("SoulburnScripts_elementSelectByFace",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/elementSelectByFace.ms"
	on execute do elementSelectByFaceDefaults()
	on Altexecute type do elementSelectByFaceUI()
	)
	
MacroScript elementSelectByFaceUI category:"SoulburnScripts" tooltip:"elementSelectByFaceUI" Icon:#("SoulburnScripts_elementSelectByFaceUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/elementSelectByFace.ms"
	elementSelectByFaceUI()
	)

MacroScript geometryBanger category:"SoulburnScripts" tooltip:"geometryBanger" Icon:#("SoulburnScripts_geometryBanger",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/geometryBanger.ms"
	on execute do geometryBangerDefaults()
	on Altexecute type do geometryBangerUI()
	)
	
MacroScript geometryBangerUI category:"SoulburnScripts" tooltip:"geometryBangerUI" Icon:#("SoulburnScripts_geometryBangerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/geometryBanger.ms"
	geometryBangerUI()
	)

MacroScript groupWithPoint category:"SoulburnScripts" tooltip:"groupWithPoint" Icon:#("SoulburnScripts_groupWithPoint",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/groupWithPoint.ms"
	on execute do groupWithPointDefaults()
	on Altexecute type do groupWithPointUI()
	)

MacroScript groupWithPointUI category:"SoulburnScripts" tooltip:"groupWithPointUI" Icon:#("SoulburnScripts_groupWithPointUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/groupWithPoint.ms"
	groupWithPointUI()
	)
	
MacroScript groupWithPointGroup category:"SoulburnScripts" tooltip:"groupWithPointGroup" Icon:#("SoulburnScripts_groupWithPointGroup",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/groupWithPoint.ms"
	on execute do groupWithPoint 1 1 true 100 true 2 1
	on Altexecute type do groupWithPointUI()
	)
	
MacroScript groupWithPointUnGroup category:"SoulburnScripts" tooltip:"groupWithPointUnGroup" Icon:#("SoulburnScripts_groupWithPointUnGroup",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/groupWithPoint.ms"
	on execute do groupWithPoint 2 1 true 100 true 2 1
	on Altexecute type do groupWithPointUI()
	)

MacroScript iDSetter category:"SoulburnScripts" tooltip:"iDSetter" Icon:#("SoulburnScripts_iDSetter",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/iDSetter.ms"
	on execute do iDSetterDefaults()
	on Altexecute type do iDSetterUI()
	)

MacroScript iDSetterUI category:"SoulburnScripts" tooltip:"iDSetterUI" Icon:#("SoulburnScripts_iDSetterUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/iDSetter.ms"
	iDSetterUI()
	)

MacroScript imagePlaneMaker category:"SoulburnScripts" tooltip:"imagePlaneMaker" Icon:#("SoulburnScripts_imagePlaneMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/imagePlaneMaker.ms"
	on execute do imagePlaneMakerDefaults()
	on Altexecute type do imagePlaneMakerUI()
	)
	
MacroScript imagePlaneMakerUI category:"SoulburnScripts" tooltip:"imagePlaneMakerUI" Icon:#("SoulburnScripts_imagePlaneMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/imagePlaneMaker.ms"
	imagePlaneMakerUI()
	)

MacroScript instanceFinder category:"SoulburnScripts" tooltip:"instanceFinder" Icon:#("SoulburnScripts_instanceFinder",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/instanceFinder.ms"
	on execute do instanceFinderDefaults()
	on Altexecute type do instanceFinderUI()
	)
	
MacroScript instanceFinderUI category:"SoulburnScripts" tooltip:"instanceFinderUI" Icon:#("SoulburnScripts_instanceFinderUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/instanceFinder.ms"
	instanceFinderUI()
	)

MacroScript instanceTrimmer category:"SoulburnScripts" tooltip:"instanceTrimmer" Icon:#("SoulburnScripts_instanceTrimmer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/instanceTrimmer.ms"
	on execute do instanceTrimmerDefaults()
	on Altexecute type do instanceTrimmerUI()
	)
	
MacroScript instanceTrimmerUI category:"SoulburnScripts" tooltip:"instanceTrimmerUI" Icon:#("SoulburnScripts_instanceTrimmerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/instanceTrimmer.ms"
	instanceTrimmerUI()
	)
	
MacroScript materialFromSelectedObject category:"SoulburnScripts" tooltip:"materialFromSelectedObject" Icon:#("SoulburnScripts_materialFromSelectedObject",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialFromSelectedObject.ms"
	on execute do materialFromSelectedObjectDefaults()
	on Altexecute type do materialFromSelectedObjectUI()
	)
	
MacroScript materialFromSelectedObjectUI category:"SoulburnScripts" tooltip:"materialFromSelectedObjectUI" Icon:#("SoulburnScripts_materialFromSelectedObjectUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialFromSelectedObject.ms"
	materialFromSelectedObjectUI()
	)

MacroScript materialInfoDisplayer category:"SoulburnScripts" tooltip:"materialInfoDisplayer" Icon:#("SoulburnScripts_materialInfoDisplayer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialInfoDisplayer.ms"
	on execute do materialInfoDisplayerDefaults()
	on Altexecute type do materialInfoDisplayerUI()
	)

MacroScript materialInfoDisplayerUI category:"SoulburnScripts" tooltip:"materialInfoDisplayerUI" Icon:#("SoulburnScripts_materialInfoDisplayerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialInfoDisplayer.ms"
	materialInfoDisplayerUI()
	)

MacroScript materialMover category:"SoulburnScripts" tooltip:"materialMover" Icon:#("SoulburnScripts_materialMover",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMoverDefaults()
	on Altexecute type do materialMoverUI()
	)

MacroScript materialMoverUI category:"SoulburnScripts" tooltip:"materialMoverUI" Icon:#("SoulburnScripts_materialMoverUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialMover.ms"
	materialMoverUI()
	)

MacroScript materialMoverBlankSceneMatsStandard category:"SoulburnScripts" tooltip:"materialMoverBlankSceneMatsStandard" Icon:#("SoulburnScripts_materialMoverBlankSceneMatsStandard",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 5 1 1 24 1 true 2 1 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditStandard category:"SoulburnScripts" tooltip:"materialMoverCleanMeditStandard" Icon:#("SoulburnScripts_materialMoverCleanMeditStandard",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 1 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditBrazil2 category:"SoulburnScripts" tooltip:"materialMoverCleanMeditBrazil2" Icon:#("SoulburnScripts_materialMoverCleanMeditBrazil2",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 4 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditMentalRayAD category:"SoulburnScripts" tooltip:"materialMoverCleanMeditMentalRayAD" Icon:#("SoulburnScripts_materialMoverCleanMeditMentalRayAD",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 5 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialMoverCleanMeditVrayMtl category:"SoulburnScripts" tooltip:"materialMoverCleanMeditVrayMtl" Icon:#("SoulburnScripts_materialMoverCleanMeditVray",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialMover.ms"
	on execute do materialMover 6 1 1 24 6 true 2 3 1
	on Altexecute type do materialMoverUI()
	)
	
MacroScript materialRemover category:"SoulburnScripts" tooltip:"materialRemover" Icon:#("SoulburnScripts_materialRemover",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialRemover.ms"
	on execute do materialRemoverDefaults()
	on Altexecute type do materialRemoverUI()
	)

MacroScript materialRemoverUI category:"SoulburnScripts" tooltip:"materialRemoverUI" Icon:#("SoulburnScripts_materialRemoverUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/materialRemover.ms"
	materialRemoverUI()
	)

MacroScript mirrorObjectAlongAxis category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxis" Icon:#("SoulburnScripts_mirrorObjectAlongAxis",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxisDefaults()
	on Altexecute type do mirrorObjectAlongAxisUI()
	)
	
MacroScript mirrorObjectAlongAxisUI category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisUI" Icon:#("SoulburnScripts_mirrorObjectAlongAxisUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	mirrorObjectAlongAxisUI()
	)

MacroScript mirrorObjectAlongAxisX category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisX" Icon:#("SoulburnScripts_mirrorObjectAlongAxisX",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxis 1 2 true
	on Altexecute type do mirrorObjectAlongAxisUI()
	)
	
MacroScript mirrorObjectAlongAxisY category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisY" Icon:#("SoulburnScripts_mirrorObjectAlongAxisY",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxis 2 2 true
	on Altexecute type do mirrorObjectAlongAxisUI()
	)
	
MacroScript mirrorObjectAlongAxisZ category:"SoulburnScripts" tooltip:"mirrorObjectAlongAxisZ" Icon:#("SoulburnScripts_mirrorObjectAlongAxisZ",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/mirrorObjectAlongAxis.ms"
	on execute do mirrorObjectAlongAxis 2 3 true
	on Altexecute type do mirrorObjectAlongAxisUI()
	)

MacroScript modelPreparer category:"SoulburnScripts" tooltip:"modelPreparer" Icon:#("SoulburnScripts_modelPreparer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/modelPreparer.ms"
	on execute do modelPreparerDefaults()
	on Altexecute type do modelPreparerUI()
	)

MacroScript modelPreparerUI category:"SoulburnScripts" tooltip:"modelPreparerUI" Icon:#("SoulburnScripts_modelPreparerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/modelPreparer.ms"
	modelPreparerUI()
	)

MacroScript modifierUtilities category:"SoulburnScripts" tooltip:"modifierUtilities" Icon:#("SoulburnScripts_modifierUtilities",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/modifierUtilities.ms"
	on execute do modifierUtilitiesDefaults()
	on Altexecute type do modifierUtilitiesUI()
	)

MacroScript modifierUtilitiesUI category:"SoulburnScripts" tooltip:"modifierUtilitiesUI" Icon:#("SoulburnScripts_modifierUtilitiesUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/modifierUtilities.ms"
	modifierUtilitiesUI()
	)

MacroScript nameManager category:"SoulburnScripts" tooltip:"nameManager" Icon:#("SoulburnScripts_nameManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/nameManager.ms"
	on execute do nameManagerDefaults()
	on Altexecute type do nameManagerUI()
	)

MacroScript nameManagerUI category:"SoulburnScripts" tooltip:"nameManagerUI" Icon:#("SoulburnScripts_nameManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/nameManager.ms"
	nameManagerUI()
	)

MacroScript nodeTypeDisplayer category:"SoulburnScripts" tooltip:"nodeTypeDisplayer" Icon:#("SoulburnScripts_nodeTypeDisplayer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/nodeTypeDisplayer.ms"
	on execute do nodeTypeDisplayerDefaults()
	on Altexecute type do nodeTypeDisplayerUI()
	)
	
MacroScript nodeTypeDisplayerUI category:"SoulburnScripts" tooltip:"nodeTypeDisplayerUI" Icon:#("SoulburnScripts_nodeTypeDisplayerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/nodeTypeDisplayer.ms"
	nodeTypeDisplayerUI()
	)

MacroScript objectAttacher category:"SoulburnScripts" tooltip:"objectAttacher" Icon:#("SoulburnScripts_objectAttacher",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectAttacher.ms"
	on execute do objectAttacherDefaults()
	on Altexecute type do objectAttacherUI()
	)
	
MacroScript objectAttacherUI category:"SoulburnScripts" tooltip:"objectAttacherUI" Icon:#("SoulburnScripts_objectAttacherUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectAttacher.ms"
	objectAttacherUI()
	)

MacroScript objectDetacher category:"SoulburnScripts" tooltip:"objectDetacher" Icon:#("SoulburnScripts_objectDetacher",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectDetacher.ms"
	on execute do objectDetacherDefaults()
	on Altexecute type do objectDetacherUI()
	)

MacroScript objectDetacherUI category:"SoulburnScripts" tooltip:"objectDetacherUI" Icon:#("SoulburnScripts_objectDetacherUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectDetacher.ms"
	objectDetacherUI()
	)
	
MacroScript objectDropper category:"SoulburnScripts" tooltip:"objectDropper" Icon:#("SoulburnScripts_objectDropper",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectDropper.ms"
	on execute do objectDropperDefaults()
	on Altexecute type do objectDropperUI()
	)

MacroScript objectDropperUI category:"SoulburnScripts" tooltip:"objectDropperUI" Icon:#("SoulburnScripts_objectDropperUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectDropper.ms"
	objectDropperUI()
	)

MacroScript objectPainter category:"SoulburnScripts" tooltip:"objectPainter" Icon:#("SoulburnScripts_objectPainter",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectPainter.ms"
	on execute do objectPainterDefaults()
	on Altexecute type do objectPainterUI()
	)
	
MacroScript objectPainterUI category:"SoulburnScripts" tooltip:"objectPainterUI" Icon:#("SoulburnScripts_objectPainterUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectPainter.ms"
	objectPainterUI()
	)

MacroScript objectReplacer category:"SoulburnScripts" tooltip:"objectReplacer" Icon:#("SoulburnScripts_objectReplacer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectReplacer.ms"
	on execute do objectReplacerDefaults()
	on Altexecute type do objectReplacerUI()
	)

MacroScript objectReplacerUI category:"SoulburnScripts" tooltip:"objectReplacerUI" Icon:#("SoulburnScripts_objectReplacerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectReplacer.ms"
	objectReplacerUI()
	)

MacroScript objectSelectorByMaterial category:"SoulburnScripts" tooltip:"objectSelectorByMaterial" Icon:#("SoulburnScripts_objectSelectorByMaterial",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectSelectorByMaterial.ms"
	on execute do objectSelectorByMaterialDefaults()
	on Altexecute type do objectSelectorByMaterialUI()
	)
	
MacroScript objectSelectorByMaterialUI category:"SoulburnScripts" tooltip:"objectSelectorByMaterialUI" Icon:#("SoulburnScripts_objectSelectorByMaterialUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectSelectorByMaterial.ms"
	objectSelectorByMaterialUI()
	)

MacroScript objectUniquefier category:"SoulburnScripts" tooltip:"objectUniquefier" Icon:#("SoulburnScripts_objectUniquefier",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectUniquefier.ms"
	on execute do objectUniquefierDefaults()
	on Altexecute type do objectUniquefierUI()
	)
	
MacroScript objectUniquefierUI category:"SoulburnScripts" tooltip:"objectUniquefierUI" Icon:#("SoulburnScripts_objectUniquefierUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/objectUniquefier.ms"
	objectUniquefierUI()
	)

MacroScript parameterManager category:"SoulburnScripts" tooltip:"parameterManager" Icon:#("SoulburnScripts_parameterManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/parameterManager.ms"
	on execute do parameterManagerDefaults()
	on Altexecute type do parameterManagerUI()
	)
	
MacroScript parameterManagerUI category:"SoulburnScripts" tooltip:"parameterManagerUI" Icon:#("SoulburnScripts_parameterManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/parameterManager.ms"
	parameterManagerUI()
	)

MacroScript parentSelector category:"SoulburnScripts" tooltip:"parentSelector" Icon:#("SoulburnScripts_parentSelector",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/parentSelector.ms"
	on execute do parentSelectorDefaults()
	on Altexecute type do parentSelectorUI()
	)
	
MacroScript parentSelectorUI category:"SoulburnScripts" tooltip:"parentSelectorUI" Icon:#("SoulburnScripts_parentSelectorUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/parentSelector.ms"
	parentSelectorUI()
	)

MacroScript pipeMaker category:"SoulburnScripts" tooltip:"pipeMaker" Icon:#("SoulburnScripts_pipeMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/pipeMaker.ms"
	on execute do pipeMakerDefaults()
	on Altexecute type do pipeMakerUI()
	)
	
MacroScript pipeMakerUI category:"SoulburnScripts" tooltip:"pipeMakerUI" Icon:#("SoulburnScripts_pipeMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/pipeMaker.ms"
	pipeMakerUI()
	)

MacroScript pivotPlacer category:"SoulburnScripts" tooltip:"pivotPlacer" Icon:#("SoulburnScripts_pivotPlacer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/pivotPlacer.ms"
	on execute do pivotPlacerDefaults()
	on Altexecute type do pivotPlacerUI()
	)

MacroScript pivotPlacerUI category:"SoulburnScripts" tooltip:"pivotPlacerUI" Icon:#("SoulburnScripts_pivotPlacerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/pivotPlacer.ms"
	pivotPlacerUI()
	)

MacroScript pivotPlacerExpertMode category:"SoulburnScripts" tooltip:"pivotPlacerExpertMode" Icon:#("SoulburnScripts_pivotPlacerExpertMode",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/pivotPlacer.ms"
	pivotPlacerExpertMode()
	)
	
MacroScript pivotPlacerCenter category:"SoulburnScripts" tooltip:"pivotPlacerCenter" Icon:#("SoulburnScripts_pivotPlacerCenter",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/pivotPlacer.ms"
	on execute do pivotPlacer 14 1 true 1
	on Altexecute type do pivotPlacerUI()
	)

MacroScript polyCountSelector category:"SoulburnScripts" tooltip:"polyCountSelector" Icon:#("SoulburnScripts_polyCountSelector",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/polyCountSelector.ms"
	on execute do polyCountSelectorDefaults()
	on Altexecute type do polyCountSelectorUI()
	)
	
MacroScript polyCountSelectorUI category:"SoulburnScripts" tooltip:"polyCountSelectorUI" Icon:#("SoulburnScripts_polyCountSelectorUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/polyCountSelector.ms"
	polyCountSelectorUI()
	)

MacroScript renderSizer category:"SoulburnScripts" tooltip:"renderSizer" Icon:#("SoulburnScripts_renderSizer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/renderSizer.ms"
	on execute do renderSizerDefaults()
	on Altexecute type do renderSizerUI()
	)
	
MacroScript renderSizerUI category:"SoulburnScripts" tooltip:"renderSizerUI" Icon:#("SoulburnScripts_renderSizerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/renderSizer.ms"
	renderSizerUI()
	)

MacroScript selectionRandomizer category:"SoulburnScripts" tooltip:"selectionRandomizer" Icon:#("SoulburnScripts_selectionRandomizer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/selectionRandomizer.ms"
	on execute do selectionRandomizerDefaults()
	on Altexecute type do selectionRandomizerUI()
	)

MacroScript selectionRandomizerUI category:"SoulburnScripts" tooltip:"selectionRandomizerUI" Icon:#("SoulburnScripts_selectionRandomizerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/selectionRandomizer.ms"
	selectionRandomizerUI()
	)

MacroScript softSelectionControl category:"SoulburnScripts" tooltip:"softSelectionControl" Icon:#("SoulburnScripts_softSelectionControl",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/softSelectionControl.ms"
	on execute do softSelectionControlDefaults()
	on Altexecute type do softSelectionControlUI()
	)
	
MacroScript softSelectionControlUI category:"SoulburnScripts" tooltip:"softSelectionControlUI" Icon:#("SoulburnScripts_softSelectionControlUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/softSelectionControl.ms"
	softSelectionControlUI()
	)

MacroScript soulburnAssetLoaderUI category:"SoulburnScripts" tooltip:"soulburnAssetLoaderUI" Icon:#("SoulburnScripts_soulburnAssetLoaderUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/soulburnAssetLoader.ms"
	soulburnAssetLoaderUI()
	)

MacroScript soulburnScriptsLister category:"SoulburnScripts" tooltip:"soulburnScriptsLister" Icon:#("SoulburnScripts_soulburnScriptsLister",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/soulburnScriptsLister.ms"
	on execute do soulburnScriptsListerDefaults()
	on Altexecute type do soulburnScriptsListerUI()
	)

MacroScript soulburnScriptsListerUI category:"SoulburnScripts" tooltip:"soulburnScriptsListerUI" Icon:#("SoulburnScripts_soulburnScriptsListerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/soulburnScriptsLister.ms"
	soulburnScriptsListerUI()
	)
	
MacroScript splineKnotManager category:"SoulburnScripts" tooltip:"splineKnotManager" Icon:#("SoulburnScripts_splineKnotManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splineKnotManager.ms"
	on execute do splineKnotManagerDefaults()
	on Altexecute type do splineKnotManagerUI()
	)

MacroScript splineKnotManagerUI category:"SoulburnScripts" tooltip:"splineKnotManagerUI" Icon:#("SoulburnScripts_splineKnotManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splineKnotManager.ms"
	splineKnotManagerUI()
	)
	
MacroScript splineKnotToObject category:"SoulburnScripts" tooltip:"splineKnotToObject" Icon:#("SoulburnScripts_splineKnotToObject",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splineKnotToObject.ms"
	on execute do splineKnotToObjectDefaults()
	on Altexecute type do splineKnotToObjectUI()
	)

MacroScript splineKnotToObjectUI category:"SoulburnScripts" tooltip:"splineKnotToObjectUI" Icon:#("SoulburnScripts_splineKnotToObjectUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splineKnotToObject.ms"
	splineKnotToObjectUI()
	)

MacroScript splineManager category:"SoulburnScripts" tooltip:"splineManager" Icon:#("SoulburnScripts_splineManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splineManager.ms"
	on execute do splineManagerDefaults()
	on Altexecute type do splineManagerUI()
	)

MacroScript splineManagerUI category:"SoulburnScripts" tooltip:"splineManagerUI" Icon:#("SoulburnScripts_splineManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splineManager.ms"
	splineManagerUI()
	)
	
MacroScript splinePainter category:"SoulburnScripts" tooltip:"splinePainter" Icon:#("SoulburnScripts_splinePainter",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splinePainter.ms"
	on execute do splinePainterDefaults()
	on Altexecute type do splinePainterUI()
	)

MacroScript splinePainterUI category:"SoulburnScripts" tooltip:"splinePainterUI" Icon:#("SoulburnScripts_splinePainterUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/splinePainter.ms"
	splinePainterUI()
	)
	
MacroScript subdivisionAutomator category:"SoulburnScripts" tooltip:"subdivisionAutomator" Icon:#("SoulburnScripts_subdivisionAutomator",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/subdivisionAutomator.ms"
	on execute do subdivisionAutomatorDefaults()
	on Altexecute type do subdivisionAutomatorUI()
	)

MacroScript subdivisionAutomatorUI category:"SoulburnScripts" tooltip:"subdivisionAutomatorUI" Icon:#("SoulburnScripts_subdivisionAutomatorUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/subdivisionAutomator.ms"
	subdivisionAutomatorUI()
	)

MacroScript subdivisionManager category:"SoulburnScripts" tooltip:"subdivisionManager" Icon:#("SoulburnScripts_subdivisionManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/subdivisionManager.ms"
	on execute do subdivisionManagerDefaults()
	on Altexecute type do subdivisionManagerUI()
	)

MacroScript subdivisionManagerUI category:"SoulburnScripts" tooltip:"subdivisionManagerUI" Icon:#("SoulburnScripts_subdivisionManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/subdivisionManager.ms"
	subdivisionManagerUI()
	)

MacroScript texmapBaker category:"SoulburnScripts" tooltip:"texmapBaker" Icon:#("SoulburnScripts_texmapBaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/texmapBaker.ms"
	on execute do texmapBakerDefaults()
	on Altexecute type do texmapBakerUI()
	)

MacroScript texmapBakerUI category:"SoulburnScripts" tooltip:"texmapBakerUI" Icon:#("SoulburnScripts_texmapBakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/texmapBaker.ms"
	texmapBakerUI()
	)

MacroScript texmapPreview category:"SoulburnScripts" tooltip:"texmapPreview" Icon:#("SoulburnScripts_texmapPreview",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/texmapPreview.ms"
	on execute do texmapPreviewDefaults()
	on Altexecute type do texmapPreviewUI()
	)

MacroScript texmapPreviewUI category:"SoulburnScripts" tooltip:"texmapPreviewUI" Icon:#("SoulburnScripts_texmapPreviewUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/texmapPreview.ms"
	texmapPreviewUI()
	)
	
MacroScript thinFaceSelector category:"SoulburnScripts" tooltip:"thinFaceSelector" Icon:#("SoulburnScripts_thinFaceSelector",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/thinFaceSelector.ms"
	on execute do thinFaceSelectorDefaults()
	on Altexecute type do thinFaceSelectorUI()
	)

MacroScript thinFaceSelectorUI category:"SoulburnScripts" tooltip:"thinFaceSelectorUI" Icon:#("SoulburnScripts_thinFaceSelectorUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/thinFaceSelector.ms"
	thinFaceSelectorUI()
	)

MacroScript transformRandomizer category:"SoulburnScripts" tooltip:"transformRandomizer" Icon:#("SoulburnScripts_transformRandomizer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformRandomizer.ms"
	on execute do transformRandomizerDefaults()
	on Altexecute type do transformRandomizerUI()
	)

MacroScript transformRandomizerUI category:"SoulburnScripts" tooltip:"transformRandomizerUI" Icon:#("SoulburnScripts_transformRandomizerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformRandomizer.ms"
	transformRandomizerUI()
	)
	
MacroScript transformRemover category:"SoulburnScripts" tooltip:"transformRemover" Icon:#("SoulburnScripts_transformRemover",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemoverDefaults()
	on Altexecute type do transformRemoverUI()
	)

MacroScript transformRemoverUI category:"SoulburnScripts" tooltip:"transformRemoverUI" Icon:#("SoulburnScripts_transformRemoverUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformRemover.ms"
	transformRemoverUI()
	)
	
MacroScript transformRemoverPosition category:"SoulburnScripts" tooltip:"transformRemoverPosition" Icon:#("SoulburnScripts_transformRemoverPosition",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemover true true true false false false false false false true
	on Altexecute type do transformRemoverUI()
	)
	
MacroScript transformRemoverRotation category:"SoulburnScripts" tooltip:"transformRemoverRotation" Icon:#("SoulburnScripts_transformRemoverRotation",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemover false false false true true true false false false true
	on Altexecute type do transformRemoverUI()
	)
	
MacroScript transformRemoverScale category:"SoulburnScripts" tooltip:"transformRemoverScale" Icon:#("SoulburnScripts_transformRemoverScale",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformRemover.ms"
	on execute do transformRemover false false false false false false true true true true
	on Altexecute type do transformRemoverUI()
	)

MacroScript transformSelector category:"SoulburnScripts" tooltip:"transformSelector" Icon:#("SoulburnScripts_transformSelector",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformSelector.ms"
	on execute do transformSelectorDefaults()
	on Altexecute type do transformSelectorUI()
	)
	
MacroScript transformSelectorUI category:"SoulburnScripts" tooltip:"transformSelectorUI" Icon:#("SoulburnScripts_transformSelectorUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/transformSelector.ms"
	transformSelectorUI()
	)
	
MacroScript uniqueObjectFinder category:"SoulburnScripts" tooltip:"uniqueObjectFinder" Icon:#("SoulburnScripts_uniqueObjectFinder",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uniqueObjectFinder.ms"
	on execute do uniqueObjectFinderDefaults()
	on Altexecute type do uniqueObjectFinderUI()
	)
	
MacroScript uniqueObjectFinderUI category:"SoulburnScripts" tooltip:"uniqueObjectFinderUI" Icon:#("SoulburnScripts_uniqueObjectFinderUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uniqueObjectFinder.ms"
	uniqueObjectFinderUI()
	)

MacroScript uVAreaDisplayer category:"SoulburnScripts" tooltip:"uVAreaDisplayer" Icon:#("SoulburnScripts_uVAreaDisplayer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVAreaDisplayer.ms"
	on execute do uVAreaDisplayerDefaults()
	on Altexecute type do uVAreaDisplayerUI()
	)
	
MacroScript uVAreaDisplayerUI category:"SoulburnScripts" tooltip:"uVAreaDisplayerUI" Icon:#("SoulburnScripts_uVAreaDisplayerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVAreaDisplayer.ms"
	uVAreaDisplayerUI()
	)

MacroScript uVFlattener category:"SoulburnScripts" tooltip:"uVFlattener" Icon:#("SoulburnScripts_uVFlattener",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattenerDefaults()
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerUI category:"SoulburnScripts" tooltip:"uVFlattenerUI" Icon:#("SoulburnScripts_uVFlattenerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	uVFlattenerUI()
	)
	
MacroScript uVFlattenerMinU category:"SoulburnScripts" tooltip:"uVFlattenerMinU" Icon:#("SoulburnScripts_uVFlattenerMinU",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 1 1
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerAverageU category:"SoulburnScripts" tooltip:"uVFlattenerAverageU" Icon:#("SoulburnScripts_uVFlattenerAverageU",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 2 1
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerMaxU category:"SoulburnScripts" tooltip:"uVFlattenerMaxU" Icon:#("SoulburnScripts_uVFlattenerMaxU",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 3 1
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerMinV category:"SoulburnScripts" tooltip:"uVFlattenerMinV" Icon:#("SoulburnScripts_uVFlattenerMinV",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 1 2
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerAverageV category:"SoulburnScripts" tooltip:"uVFlattenerAverageV" Icon:#("SoulburnScripts_uVFlattenerAverageV",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 2 2
	on Altexecute type do uVFlattenerUI()
	)
	
MacroScript uVFlattenerMaxV category:"SoulburnScripts" tooltip:"uVFlattenerMaxV" Icon:#("SoulburnScripts_uVFlattenerMaxV",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattener.ms"
	on execute do uVFlattener 3 2
	on Altexecute type do uVFlattenerUI()
	)

MacroScript uVFlattenMapper category:"SoulburnScripts" tooltip:"uVFlattenMapper" Icon:#("SoulburnScripts_uVFlattenMapper",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattenMapper.ms"
	on execute do uVFlattenMapperDefaults()
	on Altexecute type do uVFlattenMapperUI()
	)
	
MacroScript uVFlattenMapperUI category:"SoulburnScripts" tooltip:"uVFlattenMapperUI" Icon:#("SoulburnScripts_uVFlattenMapperUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVFlattenMapper.ms"
	uVFlattenMapperUI()
	)

MacroScript uVPlacer category:"SoulburnScripts" tooltip:"uVPlacer" Icon:#("SoulburnScripts_uVPlacer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVPlacer.ms"
	on execute do uVPlacerDefaults()
	on Altexecute type do uVPlacerUI()
	)
	
MacroScript uVPlacerUI category:"SoulburnScripts" tooltip:"uVPlacerUI" Icon:#("SoulburnScripts_uVPlacerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVPlacer.ms"
	uVPlacerUI()
	)
	
MacroScript uVTransfer category:"SoulburnScripts" tooltip:"uVTransfer" Icon:#("SoulburnScripts_uVTransfer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVTransfer.ms"
	on execute do uVTransferDefaults()
	on Altexecute type do uVTransferUI()
	)
	
MacroScript uVTransferUI category:"SoulburnScripts" tooltip:"uVTransferUI" Icon:#("SoulburnScripts_uVTransferUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uVTransfer.ms"
	uVTransferUI()
	)

MacroScript vertexEdgeFaceSelectByNormal category:"SoulburnScripts" tooltip:"vertexEdgeFaceSelectByNormal" Icon:#("SoulburnScripts_vertexEdgeFaceSelectByNormal",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertexEdgeFaceSelectByNormal.ms"
	on execute do vertexEdgeFaceSelectByNormalDefaults()
	on Altexecute type do vertexEdgeFaceSelectByNormalUI()
	)
	
MacroScript vertexEdgeFaceSelectByNormalUI category:"SoulburnScripts" tooltip:"vertexEdgeFaceSelectByNormalUI" Icon:#("SoulburnScripts_vertexEdgeFaceSelectByNormalUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertexEdgeFaceSelectByNormal.ms"
	vertexEdgeFaceSelectByNormalUI()
	)

MacroScript vertexMapDisplayer category:"SoulburnScripts" tooltip:"vertexMapDisplayer" Icon:#("SoulburnScripts_vertexMapDisplayer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertexMapDisplayer.ms"
	on execute do vertexMapDisplayerDefaults()
	on Altexecute type do vertexMapDisplayerUI()
	)
	
MacroScript vertexMapDisplayerUI category:"SoulburnScripts" tooltip:"vertexMapDisplayerUI" Icon:#("SoulburnScripts_vertexMapDisplayerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertexMapDisplayer.ms"
	vertexMapDisplayerUI()
	)
	
MacroScript vertPlacer category:"SoulburnScripts" tooltip:"vertPlacer" Icon:#("SoulburnScripts_vertPlacer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacerDefaults()
	on Altexecute type do vertPlacerUI()
	)
	
MacroScript vertPlacerUI category:"SoulburnScripts" tooltip:"vertPlacerUI" Icon:#("SoulburnScripts_vertPlacerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertPlacer.ms"
	vertPlacerUI()
	)
	
MacroScript vertPlacerXMouseClick category:"SoulburnScripts" tooltip:"vertPlacerXMouseclick" Icon:#("SoulburnScripts_vertPlacerXMouseclick",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacer true false false 3 0.00
	on Altexecute type do vertPlacerUI()
	)
	
MacroScript vertPlacerYMouseClick category:"SoulburnScripts" tooltip:"vertPlacerYMouseclick" Icon:#("SoulburnScripts_vertPlacerYMouseclick",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacer false true false 3 0.00
	on Altexecute type do vertPlacerUI()
	)
	
MacroScript vertPlacerZMouseClick category:"SoulburnScripts" tooltip:"vertPlacerZMouseclick" Icon:#("SoulburnScripts_vertPlacerZMouseclick",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertPlacer.ms"
	on execute do vertPlacer false false true 3 0.00
	on Altexecute type do vertPlacerUI()
	)

MacroScript vertSelectionToObject category:"SoulburnScripts" tooltip:"vertSelectionToObject" Icon:#("SoulburnScripts_vertSelectionToObject",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertSelectionToObject.ms"
	on execute do vertSelectionToObjectDefaults()
	on Altexecute type do vertSelectionToObjectUI()
	)

MacroScript vertSelectionToObjectUI category:"SoulburnScripts" tooltip:"vertSelectionToObjectUI" Icon:#("SoulburnScripts_vertSelectionToObjectUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vertSelectionToObject.ms"
	vertSelectionToObjectUI()
	)

MacroScript viewportToVFBLoader category:"SoulburnScripts" tooltip:"viewportToVFBLoader" Icon:#("SoulburnScripts_viewportToVFBLoader",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/viewportToVFBLoader.ms"
	on execute do viewportToVFBLoaderDefaults()
	on Altexecute type do viewportToVFBLoaderUI()
	)
	
MacroScript viewportToVFBLoaderUI category:"SoulburnScripts" tooltip:"viewportToVFBLoaderUI" Icon:#("SoulburnScripts_viewportToVFBLoaderUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/viewportToVFBLoader.ms"
	viewportToVFBLoaderUI()
	)

MacroScript vrayMatteManager category:"SoulburnScripts" tooltip:"vrayMatteManager" Icon:#("SoulburnScripts_vrayMatteManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vrayMatteManager.ms"
	on execute do vrayMatteManagerDefaults()
	on Altexecute type do vrayMatteManagerUI()
	)
	
MacroScript vrayMatteManagerUI category:"SoulburnScripts" tooltip:"vrayMatteManagerUI" Icon:#("SoulburnScripts_vrayMatteManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vrayMatteManager.ms"
	vrayMatteManagerUI()
	)

MacroScript vraySamplingSubdivManager category:"SoulburnScripts" tooltip:"vraySamplingSubdivManager" Icon:#("SoulburnScripts_vraySamplingSubdivManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vraySamplingSubdivManager.ms"
	on execute do vraySamplingSubdivManagerDefaults()
	on Altexecute type do vraySamplingSubdivManagerUI()
	)
	
MacroScript vraySamplingSubdivManagerUI category:"SoulburnScripts" tooltip:"vraySamplingSubdivManagerUI" Icon:#("SoulburnScripts_vraySamplingSubdivManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/vraySamplingSubdivManager.ms"
	vraySamplingSubdivManagerUI()
	)

MacroScript wireMaker category:"SoulburnScripts" tooltip:"wireMaker" Icon:#("SoulburnScripts_wireMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/wireMaker.ms"
	on execute do wireMakerDefaults()
	on Altexecute type do wireMakerUI()
	)
	
MacroScript wireMakerUI category:"SoulburnScripts" tooltip:"wireMakerUI" Icon:#("SoulburnScripts_wireMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/wireMaker.ms"
	wireMakerUI()
	)
	
MacroScript wireColorRandomizer category:"SoulburnScripts" tooltip:"wireColorRandomizer" Icon:#("SoulburnScripts_wireColorRandomizer",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/wireColorRandomizer.ms"
	on execute do wireColorRandomizerDefaults()
	on Altexecute type do wireColorRandomizerUI()
	)
	
MacroScript wireColorRandomizerUI category:"SoulburnScripts" tooltip:"wireColorRandomizerUI" Icon:#("SoulburnScripts_wireColorRandomizerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/wireColorRandomizer.ms"
	wireColorRandomizerUI()
	)
	
-- ============================================================
-- SoulBurn 2027 New Scripts
-- ============================================================

MacroScript arnoldMaterialManager category:"SoulburnScripts" tooltip:"arnoldMaterialManager" Icon:#("SoulburnScripts_arnoldMaterialManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/arnoldMaterialManager.ms"
	on execute do arnoldMaterialManagerDefaults()
	on Altexecute type do arnoldMaterialManagerUI()
	)

MacroScript arnoldMaterialManagerUI category:"SoulburnScripts" tooltip:"arnoldMaterialManagerUI" Icon:#("SoulburnScripts_arnoldMaterialManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/arnoldMaterialManager.ms"
	arnoldMaterialManagerUI()
	)

MacroScript coronaMaterialManager category:"SoulburnScripts" tooltip:"coronaMaterialManager" Icon:#("SoulburnScripts_coronaMaterialManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/coronaMaterialManager.ms"
	on execute do coronaMaterialManagerDefaults()
	on Altexecute type do coronaMaterialManagerUI()
	)

MacroScript coronaMaterialManagerUI category:"SoulburnScripts" tooltip:"coronaMaterialManagerUI" Icon:#("SoulburnScripts_coronaMaterialManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/coronaMaterialManager.ms"
	coronaMaterialManagerUI()
	)

MacroScript physicalCameraManager category:"SoulburnScripts" tooltip:"physicalCameraManager" Icon:#("SoulburnScripts_physicalCameraManager",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/physicalCameraManager.ms"
	on execute do physicalCameraManagerDefaults()
	on Altexecute type do physicalCameraManagerUI()
	)

MacroScript physicalCameraManagerUI category:"SoulburnScripts" tooltip:"physicalCameraManagerUI" Icon:#("SoulburnScripts_physicalCameraManagerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/physicalCameraManager.ms"
	physicalCameraManagerUI()
	)

MacroScript oslMapBrowser category:"SoulburnScripts" tooltip:"oslMapBrowser" Icon:#("SoulburnScripts_oslMapBrowser",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/oslMapBrowser.ms"
	on execute do oslMapBrowserDefaults()
	on Altexecute type do oslMapBrowserUI()
	)

MacroScript oslMapBrowserUI category:"SoulburnScripts" tooltip:"oslMapBrowserUI" Icon:#("SoulburnScripts_oslMapBrowserUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/oslMapBrowser.ms"
	oslMapBrowserUI()
	)

MacroScript gltfExportHelper category:"SoulburnScripts" tooltip:"gltfExportHelper" Icon:#("SoulburnScripts_gltfExportHelper",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/gltfExportHelper.ms"
	on execute do gltfExportHelperDefaults()
	on Altexecute type do gltfExportHelperUI()
	)

MacroScript gltfExportHelperUI category:"SoulburnScripts" tooltip:"gltfExportHelperUI" Icon:#("SoulburnScripts_gltfExportHelperUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/gltfExportHelper.ms"
	gltfExportHelperUI()
	)

MacroScript cinematicCameraMaker category:"SoulburnScripts" tooltip:"cinematicCameraMaker" Icon:#("SoulburnScripts_cinematicCameraMaker",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cinematicCameraMaker.ms"
	on execute do cinematicCameraMakerDefaults()
	on Altexecute type do cinematicCameraMakerUI()
	)

MacroScript cinematicCameraMakerUI category:"SoulburnScripts" tooltip:"cinematicCameraMakerUI" Icon:#("SoulburnScripts_cinematicCameraMakerUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/cinematicCameraMaker.ms"
	cinematicCameraMakerUI()
	)

MacroScript tyflowFXLauncher category:"SoulburnScripts" tooltip:"tyflowFXLauncher" Icon:#("SoulburnScripts_tyflowFXLauncher",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/tyflowFXLauncher.ms"
	on execute do tyflowFXLauncherDefaults()
	on Altexecute type do tyflowFXLauncherUI()
	)

MacroScript tyflowFXLauncherUI category:"SoulburnScripts" tooltip:"tyflowFXLauncherUI" Icon:#("SoulburnScripts_tyflowFXLauncherUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/tyflowFXLauncher.ms"
	tyflowFXLauncherUI()
	)

MacroScript atlasBridgeLauncher category:"SoulburnScripts" tooltip:"atlasBridgeLauncher" Icon:#("SoulburnScripts_atlasBridgeLauncher",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/atlasBridgeLauncher.ms"
	on execute do atlasBridgeLauncherDefaults()
	on Altexecute type do atlasBridgeLauncherUI()
	)

MacroScript atlasBridgeLauncherUI category:"SoulburnScripts" tooltip:"atlasBridgeLauncherUI" Icon:#("SoulburnScripts_atlasBridgeLauncherUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/atlasBridgeLauncher.ms"
	atlasBridgeLauncherUI()
	)

MacroScript atlasCineSceneBuilder category:"SoulburnScripts" tooltip:"atlasCineSceneBuilder" Icon:#("SoulburnScripts_atlasCineSceneBuilder",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/atlasCineSceneBuilder.ms"
	on execute do atlasCineSceneBuilderDefaults()
	on Altexecute type do atlasCineSceneBuilderUI()
	)

MacroScript atlasCineSceneBuilderUI category:"SoulburnScripts" tooltip:"atlasCineSceneBuilderUI" Icon:#("SoulburnScripts_atlasCineSceneBuilderUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/atlasCineSceneBuilder.ms"
	atlasCineSceneBuilderUI()
	)

MacroScript maxMazeGenerator category:"SoulburnScripts" tooltip:"maxMazeGenerator" Icon:#("SoulburnScripts_maxMazeGenerator",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/maxMazeGenerator.ms"
	on execute do maxMazeGeneratorDefaults()
	on Altexecute type do maxMazeGeneratorUI()
	)

MacroScript maxMazeGeneratorUI category:"SoulburnScripts" tooltip:"maxMazeGeneratorUI" Icon:#("SoulburnScripts_maxMazeGeneratorUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/maxMazeGenerator.ms"
	maxMazeGeneratorUI()
	)

MacroScript customLightingAssistant category:"SoulburnScripts" tooltip:"customLightingAssistant" Icon:#("SoulburnScripts_customLightingAssistant",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/customLightingAssistant.ms"
	on execute do customLightingAssistantDefaults()
	on Altexecute type do customLightingAssistantUI()
	)

MacroScript customLightingAssistantUI category:"SoulburnScripts" tooltip:"customLightingAssistantUI" Icon:#("SoulburnScripts_customLightingAssistantUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/customLightingAssistant.ms"
	customLightingAssistantUI()
	)

MacroScript smartLighting category:"SoulburnScripts" tooltip:"smartLighting" Icon:#("SoulburnScripts_smartLighting",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/smart_lighting.ms"
	on execute do smartLightingDefaults()
	on Altexecute type do smartLightingUI()
	)

MacroScript smartLightingUI category:"SoulburnScripts" tooltip:"smartLightingUI" Icon:#("SoulburnScripts_smartLightingUI",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/smart_lighting.ms"
	smartLightingUI()
	)

MacroScript uninstallSoulburn
category:"SoulburnScripts"
tooltip:"Uninstall SoulBurn Scripts Pack"
Icon:#("SoulburnScripts_uninstallSoulburn",1)
	(
	Include "$userScripts/SoulburnScripts/scripts/uninstall_soulburn.ms"
	on execute do uninstallSoulburn()
	)

)
-------------------------------------------------------------------------------