"""
make_cuix.py  –  Rebuild SoulburnScripts.cuix with ALL 206 macros.

Usage:
    python SB2027/tools/make_cuix.py
"""

import re
import os
import textwrap

# ---------------------------------------------------------------------------
# Macro groups (order matters – they become toolbar sections separated by a
# CTB_SEPARATOR).  Every name here MUST match a MacroScript name in the .mcr.
# ---------------------------------------------------------------------------
GROUPS = [
    ("Align / View", [
        "aligner", "alignerUI",
        "alignerSelectModePosition", "alignerSelectModeRotation", "alignerSelectModeScale",
        "alignViewportToFace", "alignViewportToFaceUI",
        "cameraFromPerspView", "cameraFromPerspViewUI",
    ]),
    ("Bitmap / Asset / Image", [
        "bitmapCollector", "bitmapCollectorUI",
        "soulburnAssetLoaderUI",
        "imagePlaneMaker", "imagePlaneMakerUI",
    ]),
    ("Blended Maps", [
        "blendedBoxMapMaker", "blendedBoxMapMakerUI",
        "blendedBoxMapManager", "blendedBoxMapManagerUI",
        "blendedCubeProjectionMaker", "blendedCubeProjectionMakerUI",
        "blendedCubeProjectionManager", "blendedCubeProjectionManagerUI",
    ]),
    ("Camera", [
        "cameraLensPackager", "cameraLensPackagerUI",
        "cameraMapTemplateRenderer", "cameraMapTemplateRendererUI",
        "physicalCameraManager", "physicalCameraManagerUI",
        "cinematicCameraMaker", "cinematicCameraMakerUI",
    ]),
    ("Geometry / Modeling", [
        "circleArrayMaker", "circleArrayMakerUI",
        "curvatureMaker", "curvatureMakerUI",
        "curvatureManager", "curvatureManagerUI",
        "edgeDivider", "edgeDividerUI",
        "edgeDivider2", "edgeDivider3", "edgeDivider4",
        "edgeSelectByAngle", "edgeSelectByAngleUI",
        "elementSelectByFace", "elementSelectByFaceUI",
        "geometryBanger", "geometryBangerUI",
        "groupWithPoint", "groupWithPointUI",
        "groupWithPointGroup", "groupWithPointUnGroup",
        "mirrorObjectAlongAxis", "mirrorObjectAlongAxisUI",
        "mirrorObjectAlongAxisX", "mirrorObjectAlongAxisY", "mirrorObjectAlongAxisZ",
        "modifierUtilities", "modifierUtilitiesUI",
        "pipeMaker", "pipeMakerUI",
        "thinFaceSelector", "thinFaceSelectorUI",
        "wireMaker", "wireMakerUI",
    ]),
    ("ID / Name / Node", [
        "customAttributeRemover", "customAttributeRemoverUI",
        "iDSetter", "iDSetterUI",
        "nameManager", "nameManagerUI",
        "nodeTypeDisplayer", "nodeTypeDisplayerUI",
        "parameterManager", "parameterManagerUI",
        "polyCountSelector", "polyCountSelectorUI",
        "renderSizer", "renderSizerUI",
    ]),
    ("Instance / Unique", [
        "instanceFinder", "instanceFinderUI",
        "instanceTrimmer", "instanceTrimmerUI",
        "objectUniquefier", "objectUniquefierUI",
        "uniqueObjectFinder", "uniqueObjectFinderUI",
    ]),
    ("Material", [
        "arnoldMaterialManager", "arnoldMaterialManagerUI",
        "coronaMaterialManager", "coronaMaterialManagerUI",
        "materialFromSelectedObject", "materialFromSelectedObjectUI",
        "materialInfoDisplayer", "materialInfoDisplayerUI",
        "materialMover", "materialMoverUI",
        "materialMoverBlankSceneMatsStandard",
        "materialMoverCleanMeditStandard",
        "materialMoverCleanMeditBrazil2",
        "materialMoverCleanMeditMentalRayAD",
        "materialMoverCleanMeditVrayMtl",
        "materialRemover", "materialRemoverUI",
        "objectSelectorByMaterial", "objectSelectorByMaterialUI",
        "oslMapBrowser", "oslMapBrowserUI",
        "vrayMatteManager", "vrayMatteManagerUI",
    ]),
    ("Object", [
        "modelPreparer", "modelPreparerUI",
        "objectAttacher", "objectAttacherUI",
        "objectDetacher", "objectDetacherUI",
        "objectDropper", "objectDropperUI",
        "objectPainter", "objectPainterUI",
        "objectReplacer", "objectReplacerUI",
    ]),
    ("Pivot / Transform", [
        "parentSelector", "parentSelectorUI",
        "pivotPlacer", "pivotPlacerUI",
        "pivotPlacerExpertMode", "pivotPlacerCenter",
        "softSelectionControl", "softSelectionControlUI",
        "transformRandomizer", "transformRandomizerUI",
        "transformRemover", "transformRemoverUI",
        "transformRemoverPosition", "transformRemoverRotation", "transformRemoverScale",
        "transformSelector", "transformSelectorUI",
        "vertPlacer", "vertPlacerUI",
        "vertPlacerXMouseClick", "vertPlacerYMouseClick", "vertPlacerZMouseClick",
    ]),
    ("Selection", [
        "selectionRandomizer", "selectionRandomizerUI",
        "vertexEdgeFaceSelectByNormal", "vertexEdgeFaceSelectByNormalUI",
    ]),
    ("Spline", [
        "splineKnotManager", "splineKnotManagerUI",
        "splineKnotToObject", "splineKnotToObjectUI",
        "splineManager", "splineManagerUI",
        "splinePainter", "splinePainterUI",
    ]),
    ("Subdivision", [
        "subdivisionAutomator", "subdivisionAutomatorUI",
        "subdivisionManager", "subdivisionManagerUI",
    ]),
    ("Texmap / UV", [
        "texmapBaker", "texmapBakerUI",
        "texmapPreview", "texmapPreviewUI",
        "uVAreaDisplayer", "uVAreaDisplayerUI",
        "uVFlattener", "uVFlattenerUI",
        "uVFlattenerMinU", "uVFlattenerAverageU", "uVFlattenerMaxU",
        "uVFlattenerMinV", "uVFlattenerAverageV", "uVFlattenerMaxV",
        "uVFlattenMapper", "uVFlattenMapperUI",
        "uVPlacer", "uVPlacerUI",
        "uVTransfer", "uVTransferUI",
        "vertSelectionToObject", "vertSelectionToObjectUI",
        "vertexMapDisplayer", "vertexMapDisplayerUI",
        "viewportToVFBLoader", "viewportToVFBLoaderUI",
    ]),
    ("V-Ray", [
        "vraySamplingSubdivManager", "vraySamplingSubdivManagerUI",
        "wireColorRandomizer", "wireColorRandomizerUI",
    ]),
    ("Scripts / Tools", [
        "soulburnScriptsLister", "soulburnScriptsListerUI",
    ]),
    ("New Tools", [
        "gltfExportHelper", "gltfExportHelperUI",
        "tyflowFXLauncher", "tyflowFXLauncherUI",
        "atlasBridgeLauncher", "atlasBridgeLauncherUI",
        "atlasCineSceneBuilder", "atlasCineSceneBuilderUI",
        "maxMazeGenerator", "maxMazeGeneratorUI",
        "customLightingAssistant", "customLightingAssistantUI",
        "smartLighting", "smartLightingUI",
    ]),
    ("Uninstall", [
        "uninstallSoulburn",
    ]),
]

# ---------------------------------------------------------------------------
# Special-case label overrides (raw camelCase → human label).
# Keys are the exact macro names; values are the desired label strings.
# ---------------------------------------------------------------------------
LABEL_OVERRIDES = {
    "iDSetter":                           "ID Setter",
    "iDSetterUI":                         "ID Setter UI",
    "uVAreaDisplayer":                    "UV Area Displayer",
    "uVAreaDisplayerUI":                  "UV Area Displayer UI",
    "uVFlattener":                        "UV Flattener",
    "uVFlattenerUI":                      "UV Flattener UI",
    "uVFlattenerMinU":                    "UV Flattener Min U",
    "uVFlattenerAverageU":                "UV Flattener Average U",
    "uVFlattenerMaxU":                    "UV Flattener Max U",
    "uVFlattenerMinV":                    "UV Flattener Min V",
    "uVFlattenerAverageV":                "UV Flattener Average V",
    "uVFlattenerMaxV":                    "UV Flattener Max V",
    "uVFlattenMapper":                    "UV Flatten Mapper",
    "uVFlattenMapperUI":                  "UV Flatten Mapper UI",
    "uVPlacer":                           "UV Placer",
    "uVPlacerUI":                         "UV Placer UI",
    "uVTransfer":                         "UV Transfer",
    "uVTransferUI":                       "UV Transfer UI",
    "vraySamplingSubdivManager":          "VRay Subdiv Manager",
    "vraySamplingSubdivManagerUI":        "VRay Subdiv Manager UI",
    "vrayMatteManager":                   "VRay Matte Manager",
    "vrayMatteManagerUI":                 "VRay Matte Manager UI",
    "materialMoverBlankSceneMatsStandard":"MatMover Blank Standard",
    "materialMoverCleanMeditStandard":    "MatMover Clean Standard",
    "materialMoverCleanMeditBrazil2":     "MatMover Clean Brazil2",
    "materialMoverCleanMeditMentalRayAD": "MatMover Clean MentalRay",
    "materialMoverCleanMeditVrayMtl":     "MatMover Clean VRay",
    "gltfExportHelper":                   "glTF Export Helper",
    "gltfExportHelperUI":                 "glTF Export Helper UI",
    "tyflowFXLauncher":                   "tyFlow FX Launcher",
    "tyflowFXLauncherUI":                 "tyFlow FX Launcher UI",
    "atlasBridgeLauncher":                "Atlas Bridge Launcher",
    "atlasBridgeLauncherUI":              "Atlas Bridge Launcher UI",
    "atlasCineSceneBuilder":              "Atlas Cine Scene Builder",
    "atlasCineSceneBuilderUI":            "Atlas Cine Scene Builder UI",
    "soulburnAssetLoaderUI":              "Asset Loader UI",
    "uninstallSoulburn":                  "Uninstall SoulBurn",
    "vertexEdgeFaceSelectByNormal":       "Select By Normal",
    "vertexEdgeFaceSelectByNormalUI":     "Select By Normal UI",
    "vertSelectionToObject":              "Vert Selection To Object",
    "vertSelectionToObjectUI":            "Vert Selection To Object UI",
    "vertexMapDisplayer":                 "Vertex Map Displayer",
    "vertexMapDisplayerUI":               "Vertex Map Displayer UI",
    "viewportToVFBLoader":                "Viewport To VFB Loader",
    "viewportToVFBLoaderUI":              "Viewport To VFB Loader UI",
    "alignerSelectModePosition":          "Aligner Pos Mode",
    "alignerSelectModeRotation":          "Aligner Rot Mode",
    "alignerSelectModeScale":             "Aligner Scale Mode",
    "groupWithPointGroup":                "Group With Point (Group)",
    "groupWithPointUnGroup":              "Group With Point (UnGroup)",
    "mirrorObjectAlongAxisX":             "Mirror X",
    "mirrorObjectAlongAxisY":             "Mirror Y",
    "mirrorObjectAlongAxisZ":             "Mirror Z",
    "edgeDivider2":                       "Edge Divider 2",
    "edgeDivider3":                       "Edge Divider 3",
    "edgeDivider4":                       "Edge Divider 4",
    "pivotPlacerExpertMode":              "Pivot Placer Expert",
    "pivotPlacerCenter":                  "Pivot Placer Center",
    "transformRemoverPosition":           "Transform Remover Pos",
    "transformRemoverRotation":           "Transform Remover Rot",
    "transformRemoverScale":              "Transform Remover Scale",
    "vertPlacerXMouseClick":              "Vert Placer X Click",
    "vertPlacerYMouseClick":              "Vert Placer Y Click",
    "vertPlacerZMouseClick":              "Vert Placer Z Click",
    "softSelectionControl":               "Soft Selection Control",
    "softSelectionControlUI":             "Soft Selection Control UI",
    "cameraMapTemplateRenderer":          "Camera Map Renderer",
    "cameraMapTemplateRendererUI":        "Camera Map Renderer UI",
}


def camel_to_label(name: str) -> str:
    """Convert camelCase macro name to a human-readable label."""
    if name in LABEL_OVERRIDES:
        return LABEL_OVERRIDES[name]
    # Insert a space before each uppercase letter that follows a lowercase letter
    # or before a sequence of uppercase letters followed by a lowercase letter.
    spaced = re.sub(r'([a-z0-9])([A-Z])', r'\1 \2', name)
    spaced = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1 \2', spaced)
    return spaced.title()


SEP = '        <Item typeID="3" type="CTB_SEPARATOR" width="6" height="16" orientation="31" visible="1" />'

BUTTON_TMPL = (
    '        <Item typeID="2" type="CTB_MACROBUTTON" width="0" height="0" '
    'controlID="0" macroTypeID="3" macroType="MB_TYPE_ACTION" '
    'actionTableID="647394" imageID="-1" imageName="" '
    'actionID="{name}`SoulburnScripts" tip="{label}" label="{label}" />'
)


def build_items() -> list[str]:
    lines: list[str] = []
    for idx, (group_name, macros) in enumerate(GROUPS):
        if idx > 0:
            lines.append(SEP)
        for macro in macros:
            label = camel_to_label(macro)
            lines.append(BUTTON_TMPL.format(name=macro, label=label))
    return lines


def build_cuix(items: list[str]) -> str:
    inner = "\n".join(items)
    return textwrap.dedent("""\
        <?xml version="1.0" encoding="utf-8" ?>
        <ADSK_CUI>
            <CUIWindows>
                <Window objectName="SoulburnScripts" name="SoulburnScripts" type="N" cType="1" toolbarRows="1">
                    <Items>
        """) + inner + textwrap.dedent("""
                    </Items>
                </Window>
            </CUIWindows>
        </ADSK_CUI>
        """)


def main():
    items = build_items()
    button_count = sum(1 for l in items if "CTB_MACROBUTTON" in l)
    sep_count    = sum(1 for l in items if "CTB_SEPARATOR"   in l)

    xml = build_cuix(items)

    # Destination: repo copy
    repo_root = os.path.normpath(
        os.path.join(os.path.dirname(__file__), "..", "..")
    )
    out_path = os.path.join(repo_root, "SB2027", "MacroScripts", "SoulburnScripts.cuix")
    with open(out_path, "w", encoding="utf-8") as fh:
        fh.write(xml)

    print(f"Written  : {out_path}")
    print(f"Buttons  : {button_count}")
    print(f"Separators: {sep_count}")
    print(f"Total items: {button_count + sep_count}")

    # Verify it is parseable XML
    import xml.etree.ElementTree as ET
    try:
        ET.fromstring(xml)
        print("XML validation: PASSED")
    except ET.ParseError as exc:
        print(f"XML validation: FAILED – {exc}")
        raise


if __name__ == "__main__":
    main()
