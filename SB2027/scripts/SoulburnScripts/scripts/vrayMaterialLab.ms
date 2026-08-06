-------------------------------------------------------------------------------
-- vrayMaterialLab.ms
-- By SoulBurn 2027 Update
-- v 1.00
-- Created On: 08/06/26
-- tested using Max 2027 + V-Ray 6/7
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Required Files:
-- sLib.ms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Description:
-- A V-Ray material construction lab. Turns a set of physically grounded
-- material rules into clickable tools: recipe builders for metals, glass,
-- liquids and plastics, a multi-lobe metal builder, a thickness-calibrated
-- absorption (fog) calculator, a swirl/lathe anisotropy setup, an imperfection
-- layering system (dust, edge wear, fingerprints, micro-scratches), a material
-- auditor that flags common physical mistakes, and a shader evaluation rig.
-- Every generated map is procedural, so nothing depends on external textures.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Tutorial:
-- Run the UI version. In Recipes, pick "Red Tail-Light Lens", select the lens
-- object and hit "Build + Assign". Open the Absorption rollout, hit "Measure
-- Selection" to read the real thickness of the lens, then "Apply Fog" so the
-- red comes from absorption through the glass instead of a flat refraction
-- tint. Open Imperfections, tick Fingerprints and Dust, hit "Add Layers".
-- Finally hit "Audit Materials" to check nothing physically wrong slipped in,
-- and "Build Test Rig" to judge the result under a high contrast light setup.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Known Issues:
-- V-Ray renames material parameters occasionally between major versions. Every
-- parameter write goes through vMLSetAny, which tries a list of candidate
-- names and reports how many writes it could not perform, rather than failing
-- silently. If the report shows unset parameters, the material is still valid,
-- just less complete.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
(
-- Globals

global vrayMaterialLab
global vrayMaterialLabDefaults
global vrayMaterialLabUI
global vrayMaterialLabAudit
global vrayMaterialLabTestRig

global vMLCloseOpenUI
global vMLHelp
global vMLLoadDef
global vMLSaveDef
global vMLDefineUI
global vMLFloater

global vMLRecipeRollout
global vMLLobeRollout
global vMLFogRollout
global vMLAnisoRollout
global vMLImperfRollout
global vMLValidateRollout
global vMLReportRollout
global vMLReportFloater
global vMLReportLines

global vMLSet
global vMLSetAny
global vMLNewNoise
global vMLUnsetCount
global vMLVRayReady
global vMLNewVRayMtl
global vMLMakeMetal
global vMLMakeDielectric
global vMLRecipeName
global vMLRecipeInfo
global vMLBuildRecipe
global vMLAssignMtl
global vMLBuildLobeMetal
global vMLMeasureThickness
global vMLApplyFog
global vMLCheckWatertight
global vMLApplyAnisotropy
global vMLAddUVWForAniso
global vMLMakeDustMask
global vMLAddImperfections
global vMLTargetMtl
global vMLShowReport
global vMLNotesText

-- Includes

include "$userScripts\SoulburnScripts\lib\sLib.ms"

-- Variables

vMLRecipeValue = 1
vMLAssignValue = true
vMLBaseRoughValue = 0.12
vMLBroadRoughValue = 0.35
vMLBroadAmountValue = 0.25
vMLLobeAnisoValue = 0.0
vMLFogDepthValue = 1.0
vMLFogColorValue = (color 190 30 30)
vMLAnisoAmountValue = 0.6
vMLAnisoModeValue = 1
vMLDustValue = false
vMLEdgeWearValue = false
vMLFingerprintValue = false
vMLScratchValue = false
vMLImperfAmountValue = 0.5
vMLPosValue = sLibGetSafeUIPos 330 660

vMLUnsetCount = 0

-- Functions

-------------------------------------------------------------------------------
-- Parameter plumbing
-------------------------------------------------------------------------------

-- V-Ray parameter names drift between versions, so never write a parameter
-- directly. vMLSetAny walks a candidate list and records anything it could not
-- write, so the build report can tell the user what is missing instead of the
-- material quietly coming out wrong.

fn vMLSet obj n v =
	(
	local ok = false
	try (setProperty obj n v; ok = true) catch (ok = false)
	ok
	)

fn vMLSetAny obj names v =
	(
	for n in names do (if (vMLSet obj n v) then return true)
	vMLUnsetCount += 1
	false
	)

-- The Noise map's type / threshold parameter names differ between the
-- MaxScript exposure and the UI, so build it defensively too. uTile/vTile
-- stretch the pattern into directional streaks when asked.
fn vMLNewNoise nm sz ntype uTile vTile =
	(
	local n = Noise name:nm
	vMLSet n "size" sz
	if not (vMLSet n "type" ntype) then vMLSet n "noise_type" ntype
	if uTile != 1.0 or vTile != 1.0 then
		(
		try (n.coords.U_Tiling = uTile; n.coords.V_Tiling = vTile) catch ()
		)
	n
	)

fn vMLVRayReady =
	(
	local ok = false
	try (local m = VRayMtl(); ok = (m != undefined)) catch (ok = false)
	if not ok then MessageBox "V-Ray does not appear to be installed.\n\nvrayMaterialLab builds VRayMtl / VRayBlendMtl node graphs and needs V-Ray loaded." title:"vrayMaterialLab"
	ok
	)

fn vMLNewVRayMtl nm =
	(
	local m = VRayMtl name:nm
	-- GGX is the only distribution that behaves like a real microfacet
	-- surface across the roughness range, and roughness mode keeps the
	-- numbers in this tool readable as roughness rather than glossiness.
	vMLSetAny m #("brdf_type") 3
	vMLSetAny m #("brdf_useRoughness") true
	m
	)

-- Metal: conductor. The reflection lobe carries the tint, the diffuse does
-- not participate. Rust, dust and paint are separate substances and must not
-- be faked by tinting a metal's diffuse.
fn vMLMakeMetal nm col rough aniso =
	(
	local m = vMLNewVRayMtl nm
	vMLSetAny m #("Diffuse") col
	vMLSetAny m #("Reflection") (color 255 255 255)
	vMLSetAny m #("reflection_metalness") 1.0
	vMLSetAny m #("reflection_glossiness") rough
	vMLSetAny m #("reflection_fresnel") true
	vMLSetAny m #("reflection_lockIOR") true
	if aniso != 0.0 then vMLSetAny m #("anisotropy") aniso
	m
	)

-- Dielectric: insulator. Reflection stays white and Fresnel driven, colour
-- lives in diffuse (opaque) or in fog (transmissive).
fn vMLMakeDielectric nm col rough ior =
	(
	local m = vMLNewVRayMtl nm
	vMLSetAny m #("Diffuse") col
	vMLSetAny m #("Reflection") (color 255 255 255)
	vMLSetAny m #("reflection_metalness") 0.0
	vMLSetAny m #("reflection_glossiness") rough
	vMLSetAny m #("reflection_fresnel") true
	vMLSetAny m #("reflection_lockIOR") true
	vMLSetAny m #("reflection_ior") ior
	m
	)

fn vMLAssignMtl m =
	(
	-- Always park the result in the active Material Editor slot so it is
	-- reachable even when nothing is selected.
	try (meditMaterials[activeMeditSlot] = m) catch ()
	local n = 0
	if vMLAssignValue and selection.count > 0 then
		(
		for obj in selection do (try (obj.material = m; n += 1) catch ())
		)
	n
	)

-------------------------------------------------------------------------------
-- Recipes
-------------------------------------------------------------------------------

fn vMLRecipeName i =
	(
	local a = #("Polished Steel", "Brushed Aluminum", "Rough Cast Metal", \
		"Chrome", "Gold", "Rusted Iron (Blend)", "Car Paint + Clear Coat", \
		"Clear Glass", "Red Tail-Light Lens", "Water", "Blood", \
		"Fingerprinted Black Plastic", "Dusty Metal (Blend)")
	if i >= 1 and i <= a.count then a[i] else "Unknown"
	)

fn vMLRecipeInfo i =
	(
	local a = #( \
		"Conductor, roughness 0.12. Add a broad second lobe from the Metal Lobes rollout.", \
		"Conductor, roughness 0.28, anisotropy 0.7. Use the Anisotropy rollout to set direction.", \
		"Conductor, roughness 0.5, granular micro-bump. Sharp lobe kept weak, not absent.", \
		"Conductor, roughness 0.03. Needs a high contrast environment to read at all.", \
		"Conductor with a warm reflection tint. Diffuse carries no response.", \
		"VRayBlendMtl: bare iron base + rust dielectric coat, VRayDirt cavity mask.", \
		"Metallic base flake colour under a dielectric clear coat. Coat is not a 2nd metal.", \
		"Dielectric, IOR 1.52, white refraction. Colour comes from fog, not refraction tint.", \
		"Dielectric lens, deep red fog. Calibrate fog depth to real lens thickness.", \
		"Dielectric, IOR 1.33, very weak blue-green fog over a long distance.", \
		"Dark saturated red fog over a short distance, glossy dielectric surface.", \
		"Near-black dielectric, roughness 0.3, fingerprint variation in roughness only.", \
		"VRayBlendMtl: metal base + rough dust dielectric, gravity and cavity mask." \
		)
	if i >= 1 and i <= a.count then a[i] else ""
	)

fn vMLBuildRecipe i =
	(
	local m = undefined
	case i of
		(
		1: m = vMLMakeMetal "SB_PolishedSteel" (color 200 200 202) 0.12 0.0
		2:
			(
			m = vMLMakeMetal "SB_BrushedAluminum" (color 220 221 224) 0.28 0.7
			vMLSetAny m #("anisotropy_derivation") 0
			)
		3:
			(
			m = vMLMakeMetal "SB_RoughCastMetal" (color 150 150 152) 0.5 0.0
			local grain = vMLNewNoise "SB_CastGrain" 1.5 1 1.0 1.0
			vMLSetAny m #("texmap_bump") grain
			vMLSetAny m #("texmap_bump_multiplier") 12.0
			)
		4: m = vMLMakeMetal "SB_Chrome" (color 245 246 248) 0.03 0.0
		5: m = vMLMakeMetal "SB_Gold" (color 255 190 100) 0.15 0.0
		6:
			(
			-- Rust is iron oxide: a rough dielectric, not orange metal. It has
			-- to be its own material blended over the bare metal.
			local baseM = vMLMakeMetal "SB_BareIron" (color 140 138 135) 0.3 0.0
			local rustM = vMLMakeDielectric "SB_Rust" (color 110 55 25) 0.75 1.5
			local dirt = VRayDirt name:"SB_RustMask"
			vMLSetAny dirt #("radius") 12.0
			vMLSetAny dirt #("occluded_color") (color 255 255 255)
			vMLSetAny dirt #("unoccluded_color") (color 60 60 60)
			m = VRayBlendMtl name:"SB_RustedIron"
			vMLSetAny m #("baseMtl") baseM
			vMLSetAny m #("coatMtl_1") rustM
			vMLSetAny m #("texmap_blend_1") dirt
			vMLSetAny m #("texmap_blend_1_on") true
			)
		7:
			(
			m = vMLMakeMetal "SB_CarPaint" (color 140 20 30) 0.35 0.0
			-- The coat is a dielectric film above the metallic flake layer,
			-- which is why it gets its own IOR and its own roughness.
			vMLSetAny m #("coat_amount") 1.0
			vMLSetAny m #("coat_glossiness") 0.02
			vMLSetAny m #("coat_ior") 1.5
			vMLSetAny m #("coat_color") (color 255 255 255)
			)
		8:
			(
			m = vMLMakeDielectric "SB_ClearGlass" (color 0 0 0) 0.0 1.52
			vMLSetAny m #("Refraction") (color 255 255 255)
			vMLSetAny m #("refraction_ior") 1.52
			vMLSetAny m #("refraction_glossiness") 0.0
			vMLSetAny m #("refraction_affectShadows") true
			vMLSetAny m #("refraction_fogColor") (color 240 245 245)
			)
		9:
			(
			m = vMLMakeDielectric "SB_TailLightLens" (color 0 0 0) 0.04 1.55
			vMLSetAny m #("Refraction") (color 255 255 255)
			vMLSetAny m #("refraction_ior") 1.55
			vMLSetAny m #("refraction_glossiness") 0.02
			vMLSetAny m #("refraction_affectShadows") true
			vMLSetAny m #("refraction_fogColor") (color 200 20 20)
			vMLSetAny m #("refraction_fogMult") 1.0
			)
		10:
			(
			m = vMLMakeDielectric "SB_Water" (color 0 0 0) 0.0 1.33
			vMLSetAny m #("Refraction") (color 255 255 255)
			vMLSetAny m #("refraction_ior") 1.33
			vMLSetAny m #("refraction_affectShadows") true
			-- Almost colourless: small volumes of clean water should not tint.
			vMLSetAny m #("refraction_fogColor") (color 225 244 242)
			vMLSetAny m #("refraction_fogMult") 0.02
			)
		11:
			(
			m = vMLMakeDielectric "SB_Blood" (color 0 0 0) 0.08 1.36
			vMLSetAny m #("Refraction") (color 255 255 255)
			vMLSetAny m #("refraction_ior") 1.36
			vMLSetAny m #("refraction_glossiness") 0.1
			vMLSetAny m #("refraction_affectShadows") true
			vMLSetAny m #("refraction_fogColor") (color 90 6 6)
			vMLSetAny m #("refraction_fogMult") 8.0
			)
		12:
			(
			m = vMLMakeDielectric "SB_BlackPlastic" (color 14 14 16) 0.3 1.52
			local grain = vMLNewNoise "SB_PlasticGrain" 0.6 1 1.0 1.0
			vMLSetAny m #("texmap_bump") grain
			vMLSetAny m #("texmap_bump_multiplier") 3.0
			)
		13:
			(
			local baseM = vMLMakeMetal "SB_DustyMetalBase" (color 190 190 192) 0.2 0.0
			local dustM = vMLMakeDielectric "SB_Dust" (color 168 160 148) 0.9 1.4
			local grain = vMLNewNoise "SB_DustGrain" 0.4 1 1.0 1.0
			vMLSetAny dustM #("texmap_bump") grain
			vMLSetAny dustM #("texmap_bump_multiplier") 4.0
			m = VRayBlendMtl name:"SB_DustyMetal"
			vMLSetAny m #("baseMtl") baseM
			vMLSetAny m #("coatMtl_1") dustM
			vMLSetAny m #("texmap_blend_1") (vMLMakeDustMask())
			vMLSetAny m #("texmap_blend_1_on") true
			)
		default: m = undefined
		)
	m
	)

-------------------------------------------------------------------------------
-- Multi-lobe metal
-------------------------------------------------------------------------------

-- Many manufactured metals show more than one reflection scale: a polished
-- substrate plus a broader population left by machining or handling. One
-- roughness map cannot represent both, so the broad lobe becomes a second
-- metal blended in at a low amount. Keeping that amount low is what stops the
-- stack from rendering brighter than real metal.

fn vMLBuildLobeMetal baseRough broadRough broadAmount aniso =
	(
	vMLUnsetCount = 0
	local sharp = vMLMakeMetal "SB_Lobe_Sharp" (color 200 200 202) baseRough 0.0
	local broad = vMLMakeMetal "SB_Lobe_Broad" (color 200 200 202) broadRough 0.0
	local m = VRayBlendMtl name:"SB_MultiLobeMetal"
	vMLSetAny m #("baseMtl") sharp
	vMLSetAny m #("coatMtl_1") broad
	local a = (amax 0.0 (amin 1.0 broadAmount)) * 255.0
	vMLSetAny m #("blend_1") (color a a a)
	if aniso != 0.0 then
		(
		local dir = vMLMakeMetal "SB_Lobe_Aniso" (color 200 200 202) broadRough aniso
		vMLSetAny m #("coatMtl_2") dir
		vMLSetAny m #("blend_2") (color 90 90 90)
		)
	m
	)

-------------------------------------------------------------------------------
-- Absorption
-------------------------------------------------------------------------------

-- Transmission follows Beer-Lambert: T = e^(-sigma*d). Colour therefore has to
-- come from distance travelled through the volume (fog), not from a tint on
-- the refraction colour, or thin and thick areas will look identical.

fn vMLMeasureThickness =
	(
	if selection.count == 0 then
		(
		MessageBox "Select the transmissive object first." title:"vrayMaterialLab"
		return undefined
		)
	local bb = sLibGetCollectionBBox (selection as array)
	local dx = abs (bb[1][1] - bb[2][1])
	local dy = abs (bb[1][2] - bb[2][2])
	local dz = abs (bb[1][3] - bb[2][3])
	-- Smallest bounding box axis is the best cheap proxy for the distance a
	-- ray actually travels through a lens, a pane or a pool.
	local t = amin dx (amin dy dz)
	if t <= 0.0 then t = 1.0
	t
	)

fn vMLTargetMtl =
	(
	-- Prefer the material on the selection, fall back to the active Medit slot.
	local mats = sLibGetAllMaterialsOnSelectedObjects()
	for m in mats do (if (classof m) == VRayMtl then return m)
	local a = undefined
	try (a = meditMaterials[activeMeditSlot]) catch ()
	if a != undefined and (classof a) == VRayMtl then return a
	undefined
	)

fn vMLApplyFog depth col =
	(
	local m = vMLTargetMtl()
	if m == undefined then
		(
		MessageBox "No VRayMtl found on the selection or in the active Material Editor slot." title:"vrayMaterialLab"
		return false
		)
	vMLUnsetCount = 0
	vMLSetAny m #("Refraction") (color 255 255 255)
	vMLSetAny m #("refraction_fogColor") col
	-- V-Ray 5+ can express fog as a real scene distance. When that switch is
	-- available the depth is used literally; otherwise fog multiplier is the
	-- reciprocal, so a thicker object needs a smaller multiplier.
	local scaled = vMLSet m "refraction_fogUnitsScale_on" true
	if scaled then vMLSetAny m #("refraction_fogMult") depth
	else vMLSetAny m #("refraction_fogMult") (1.0 / (amax 0.0001 depth))
	vMLSetAny m #("refraction_affectShadows") true
	local msg = "Fog applied to " + m.name + "\n\nDepth: " + (depth as string)
	if scaled then msg += " scene units (units scale ON)"
	else msg += " -> fog multiplier " + ((1.0 / (amax 0.0001 depth)) as string)
	if vMLUnsetCount > 0 then msg += "\n\n" + (vMLUnsetCount as string) + " parameter(s) could not be written on this V-Ray version."
	MessageBox msg title:"vrayMaterialLab"
	true
	)

fn vMLCheckWatertight =
	(
	if selection.count == 0 then
		(
		MessageBox "Select the object(s) to check." title:"vrayMaterialLab"
		return false
		)
	local bad = #()
	for obj in selection do
		(
		try
			(
			local ms = snapshotAsMesh obj
			local oe = meshop.getOpenEdges ms
			if oe.numberSet > 0 then append bad (obj.name + "  (" + (oe.numberSet as string) + " open edges)")
			delete ms
			) catch ()
		)
	if bad.count == 0 then
		MessageBox "All checked objects are closed.\n\nFog absorption needs a real volume for rays to travel through, and these qualify." title:"vrayMaterialLab"
	else
		MessageBox ("Open geometry found - fog absorption will not build up correctly:\n\n" + \
			(with printAllElements true (bad as string)) + \
			"\n\nGive these objects real wall thickness, or accept a flat tint.") title:"vrayMaterialLab"
	true
	)

-------------------------------------------------------------------------------
-- Anisotropy
-------------------------------------------------------------------------------

-- Anisotropy needs two things: an amount (how stretched the highlight is) and
-- a direction. A grayscale scratch texture alone carries no direction, so the
-- swirl and lathe modes generate an actual angular field to drive rotation.

fn vMLApplyAnisotropy amount mode =
	(
	local m = vMLTargetMtl()
	if m == undefined then
		(
		MessageBox "No VRayMtl found on the selection or in the active Material Editor slot." title:"vrayMaterialLab"
		return false
		)
	vMLUnsetCount = 0
	vMLSetAny m #("anisotropy") amount
	vMLSetAny m #("anisotropy_derivation") 0

	-- Stretching the noise UVs turns isotropic fractal noise into directional
	-- groove relief that agrees with the reflection stretch.
	local scratch = vMLNewNoise "SB_AnisoScratch" 0.35 2 60.0 1.0
	vMLSetAny m #("texmap_bump") scratch
	vMLSetAny m #("texmap_bump_multiplier") 2.0

	local note = ""
	case mode of
		(
		1: note = "Linear: rotation left at 0. Align UVs to the brushing direction."
		2:
			(
			-- Gradient Ramp in Sweep mode is a continuous 0-1 angular field
			-- around the map centre, which is exactly the rotation data a
			-- circular sanding pattern needs.
			local ramp = Gradient_Ramp name:"SB_SwirlRotation"
			local ok = false
			try (ramp.gradientType = 10; ok = true) catch (ok = false)
			if (vMLSetAny m #("texmap_anisotropy_rotation") ramp) then
				(
				vMLSet m "texmap_anisotropy_rotation_on" true
				note = "Swirl: Gradient Ramp drives rotation."
				if not ok then note += " Set its type to Sweep manually."
				note += "\nCentre the object's UVs on the swirl origin."
				)
			else note = "Swirl: this V-Ray version has no anisotropy rotation map slot. Rotation left numeric."
			)
		3:
			(
			-- On a lathed part the grooves run around the axis, so aligning the
			-- material's anisotropy to the local axis is enough - no map needed.
			vMLSetAny m #("anisotropy_rotation") 0.0
			vMLSetAny m #("anisotropy_axis") 2
			note = "Lathe: anisotropy locked to the local Z axis.\nAdd a cylindrical UVW Map aligned to the turning axis."
			)
		)
	local msg = "Anisotropy " + (amount as string) + " applied to " + m.name + "\n\n" + note
	if vMLUnsetCount > 0 then msg += "\n\n" + (vMLUnsetCount as string) + " parameter(s) could not be written on this V-Ray version."
	MessageBox msg title:"vrayMaterialLab"
	true
	)

fn vMLAddUVWForAniso mode =
	(
	if selection.count == 0 then
		(
		MessageBox "Select the object(s) first." title:"vrayMaterialLab"
		return false
		)
	local n = 0
	for obj in selection do
		(
		try
			(
			local uv = UVWMap()
			case mode of
				(
				1: uv.maptype = 0		-- planar, for linear brushing
				2: uv.maptype = 0		-- planar, centred, for swirl
				3: uv.maptype = 1		-- cylindrical, for lathe work
				)
			uv.length = 1; uv.width = 1; uv.height = 1
			addModifier obj uv
			uv.fitToObject()
			n += 1
			) catch ()
		)
	MessageBox ((n as string) + " UVW Map modifier(s) added and fitted.\n\nRotate the gizmo until the visible grooves follow the manufacturing direction.") title:"vrayMaterialLab"
	true
	)

-------------------------------------------------------------------------------
-- Imperfections
-------------------------------------------------------------------------------

-- Each imperfection has its own physical cause and therefore its own map and
-- its own channel. Reusing one texture across colour, roughness and bump makes
-- every effect perfectly correlated, which no real surface is.

fn vMLMakeDustMask =
	(
	-- Dust settles from above and collects in cavities, so the mask is a
	-- gravity term and a cavity term, broken up by noise.
	local up = Falloff name:"SB_DustGravity"
	try (up.type = 0; up.direction = 9) catch ()
	local cav = VRayDirt name:"SB_DustCavity"
	vMLSetAny cav #("radius") 8.0
	vMLSetAny cav #("occluded_color") (color 255 255 255)
	vMLSetAny cav #("unoccluded_color") (color 0 0 0)
	local breakup = vMLNewNoise "SB_DustBreakup" 25.0 1 1.0 1.0
	local mixMap = Mix name:"SB_DustMask"
	try (mixMap.map1 = up; mixMap.map2 = cav; mixMap.mask = breakup) catch ()
	mixMap
	)

fn vMLAddImperfections doDust doEdge doPrint doScratch amount =
	(
	local m = vMLTargetMtl()
	if m == undefined then
		(
		MessageBox "No VRayMtl found on the selection or in the active Material Editor slot." title:"vrayMaterialLab"
		return false
		)
	if not (doDust or doEdge or doPrint or doScratch) then
		(
		MessageBox "Tick at least one imperfection layer." title:"vrayMaterialLab"
		return false
		)
	vMLUnsetCount = 0
	local added = #()
	local result = m

	if doPrint then
		(
		-- Fingerprints are an oil film. They change reflection long before
		-- they change colour, so they belong in roughness only.
		local fp = vMLNewNoise "SB_Fingerprints" 2.5 1 1.0 1.0
		if not (vMLSet fp "thresholdHigh" 0.65) then vMLSet fp "high" 0.65
		if not (vMLSet fp "thresholdLow" 0.35) then vMLSet fp "low" 0.35
		if (vMLSetAny m #("texmap_reflectionGlossiness") fp) then
			(
			vMLSet m "texmap_reflectionGlossiness_on" true
			vMLSetAny m #("texmap_reflectionGlossiness_multiplier") (amount * 60.0)
			append added "Fingerprints -> reflection roughness"
			)
		)

	if doScratch then
		(
		-- Micro-scratches are shallow relief. Bump, never displacement.
		local sc = vMLNewNoise "SB_MicroScratches" 0.15 2 40.0 2.0
		vMLSetAny m #("texmap_bump") sc
		vMLSetAny m #("texmap_bump_multiplier") (amount * 4.0)
		append added "Micro-scratches -> bump"
		)

	if doEdge then
		(
		-- Contact wear lives on convex edges, so the dirt map is inverted.
		local wear = VRayDirt name:"SB_EdgeWear"
		vMLSetAny wear #("radius") 3.0
		vMLSetAny wear #("invert_normal") true
		vMLSetAny wear #("occluded_color") (color 255 255 255)
		vMLSetAny wear #("unoccluded_color") (color 40 40 40)
		local worn = vMLMakeMetal "SB_WornMetal" (color 210 210 212) 0.18 0.0
		local b = VRayBlendMtl name:"SB_EdgeWorn"
		vMLSetAny b #("baseMtl") result
		vMLSetAny b #("coatMtl_1") worn
		vMLSetAny b #("texmap_blend_1") wear
		vMLSetAny b #("texmap_blend_1_on") true
		result = b
		append added "Edge wear -> VRayBlendMtl coat, VRayDirt convex mask"
		)

	if doDust then
		(
		-- Dust is a separate rough dielectric deposit sitting on top, not a
		-- lightening of the base colour.
		local dustM = vMLMakeDielectric "SB_DustLayer" (color 168 160 148) 0.9 1.4
		local grain = vMLNewNoise "SB_DustGrain" 0.4 1 1.0 1.0
		vMLSetAny dustM #("texmap_bump") grain
		vMLSetAny dustM #("texmap_bump_multiplier") 4.0
		local b = VRayBlendMtl name:"SB_Dusted"
		vMLSetAny b #("baseMtl") result
		vMLSetAny b #("coatMtl_1") dustM
		vMLSetAny b #("texmap_blend_1") (vMLMakeDustMask())
		vMLSetAny b #("texmap_blend_1_on") true
		result = b
		append added "Dust -> VRayBlendMtl coat, gravity + cavity mask"
		)

	if result != m then
		(
		try (meditMaterials[activeMeditSlot] = result) catch ()
		if vMLAssignValue and selection.count > 0 then
			(for obj in selection do (try (obj.material = result) catch ()))
		)

	local msg = "Layers added:\n\n"
	for a in added do msg += "  - " + a + "\n"
	if result != m then msg += "\nResult material: " + result.name + " (assigned to the active Medit slot)."
	if vMLUnsetCount > 0 then msg += "\n\n" + (vMLUnsetCount as string) + " parameter(s) could not be written on this V-Ray version."
	MessageBox msg title:"vrayMaterialLab"
	true
	)

-------------------------------------------------------------------------------
-- Audit
-------------------------------------------------------------------------------

fn vMLShowReport title lines =
	(
	-- A rollout handler cannot reference an OUTER LOCAL. Using the `lines`
	-- parameter inside "on vMLReportPrint pressed" failed to compile with
	--   No outer local variable references permitted here
	-- and because that aborts the whole file, every macro in the pack stopped
	-- registering and the entire toolbar went dead. Hand the data to the
	-- rollout through a global instead.
	global vMLReportLines = lines
	if vMLReportFloater != undefined then (try (CloseRolloutFloater vMLReportFloater) catch ())
	rollout vMLReportRollout title
		(
		listbox vMLReportList "" items:vMLReportLines height:22 width:430 pos:[5,5]
		button vMLReportPrint "Print To Listener" width:140 pos:[5,375]
		on vMLReportPrint pressed do (for l in vMLReportLines do format "%\n" l)
		button vMLReportClose "Close" width:80 pos:[150,375]
		on vMLReportClose pressed do (try (CloseRolloutFloater vMLReportFloater) catch ())
		)
	local p = sLibGetSafeUIPos 450 430
	vMLReportFloater = newRolloutFloater title 450 430 p.x p.y
	addRollout vMLReportRollout vMLReportFloater
	)

-- The auditor encodes the failure modes that make V-Ray materials read as
-- fake: colour in the wrong slot, conductors used as paint, one texture reused
-- across every channel, data maps interpreted as sRGB, and volumes with no
-- volume. It reports; it never edits.

fn vrayMaterialLabAudit =
	(
	local mats = #()
	local scope = ""
	if selection.count > 0 then
		(
		mats = sLibGetAllMaterialsOnSelectedObjects()
		scope = "selection (" + (selection.count as string) + " objects)"
		)
	else
		(
		mats = sLibGetAllSceneMaterials()
		scope = "whole scene"
		)

	local lines = #()
	append lines ("vrayMaterialLab audit - scope: " + scope)
	append lines ("Materials examined: " + (mats.count as string))
	append lines "-------------------------------------------------------------"
	local issues = 0

	fn vMLIsGrey c = (abs (c.r - c.g) < 12 and abs (c.g - c.b) < 12)

	for m in mats do
		(
		if (classof m) != VRayMtl then continue
		local nm = m.name
		local refr = undefined
		local fogc = undefined
		local metal = 0.0
		local rough = undefined
		local diff = undefined
		try (refr = getProperty m "Refraction") catch ()
		try (fogc = getProperty m "refraction_fogColor") catch ()
		try (metal = getProperty m "reflection_metalness") catch ()
		try (rough = getProperty m "reflection_glossiness") catch ()
		try (diff = getProperty m "Diffuse") catch ()

		local transmissive = (refr != undefined and (refr.r + refr.g + refr.b) > 12)

		if transmissive then
			(
			if not (vMLIsGrey refr) then
				(
				append lines (nm + ": refraction colour is tinted.")
				append lines "   Put the colour in fog instead - a refraction tint does not vary with thickness."
				issues += 1
				)
			if fogc != undefined and vMLIsGrey fogc and fogc.r > 240 then
				(
				append lines (nm + ": transmissive but fog is white - no absorption at all.")
				append lines "   Use the Absorption rollout to calibrate fog colour and depth to real thickness."
				issues += 1
				)
			)

		if metal > 0.5 then
			(
			if diff != undefined and not (vMLIsGrey diff) and (diff.r + diff.g + diff.b) > 60 then
				(
				append lines (nm + ": metalness is on and diffuse is strongly tinted.")
				append lines "   A conductor's diffuse does not respond. Rust, paint or oxide belong in a blended dielectric."
				issues += 1
				)
			if rough != undefined and rough < 0.005 then
				(
				append lines (nm + ": a single perfectly sharp lobe.")
				append lines "   Real metal shows a second, broader reflection population. See the Metal Lobes rollout."
				issues += 1
				)
			)

		-- One texture reused across several channels correlates every effect.
		local used = #()
		local dupFound = false
		for slotName in #("texmap_diffuse", "texmap_reflectionGlossiness", "texmap_bump", "texmap_displacement", "texmap_reflection") do
			(
			local t = undefined
			try (t = getProperty m slotName) catch ()
			if t != undefined then
				(
				if (finditem used t) > 0 then dupFound = true
				else append used t
				)
			)
		if dupFound then
			(
			append lines (nm + ": the same map object is wired into more than one channel.")
			append lines "   Separate the causes - dirt, oil, scratches and pitting are different maps."
			issues += 1
			)

		-- Data maps read through an sRGB transform gain contrast they should
		-- not have, which shows up as unnaturally hard rough/smooth patches.
		for slotName in #("texmap_reflectionGlossiness", "texmap_bump", "texmap_displacement") do
			(
			local t = undefined
			try (t = getProperty m slotName) catch ()
			if t != undefined and (classof t) == Bitmaptexture then
				(
				local g = 1.0
				try (g = t.bitmap.gamma) catch ()
				if g != undefined and abs (g - 1.0) > 0.05 then
					(
					append lines (nm + ": " + slotName + " bitmap is not linear (gamma " + (g as string) + ").")
					append lines "   Load roughness, bump, normal and mask maps as data / non-colour."
					issues += 1
					)
				)
			)

		local bm = undefined
		try (bm = getProperty m "texmap_bump_multiplier") catch ()
		if bm != undefined and bm > 100.0 then
			(
			append lines (nm + ": bump multiplier is " + (bm as string) + ".")
			append lines "   Values this high read as noise rather than surface relief."
			issues += 1
			)
		)

	-- A volume material on open geometry cannot accumulate absorption.
	if selection.count > 0 then
		(
		for obj in selection do
			(
			local hasFog = false
			try
				(
				local mm = obj.material
				if mm != undefined and (classof mm) == VRayMtl then
					(
					local r = getProperty mm "Refraction"
					hasFog = ((r.r + r.g + r.b) > 12)
					)
				) catch ()
			if hasFog then
				(
				try
					(
					local ms = snapshotAsMesh obj
					local oe = meshop.getOpenEdges ms
					if oe.numberSet > 0 then
						(
						append lines (obj.name + ": transmissive material on open geometry (" + (oe.numberSet as string) + " open edges).")
						append lines "   Absorption needs a closed volume with real wall thickness."
						issues += 1
						)
					delete ms
					) catch ()
				)
			)
		)

	append lines "-------------------------------------------------------------"
	if issues == 0 then append lines "No physical issues found."
	else append lines ("Issues found: " + (issues as string))
	vMLShowReport "vrayMaterialLab - Audit" lines
	issues
	)

-------------------------------------------------------------------------------
-- Test rig
-------------------------------------------------------------------------------

-- A metal cannot be judged in a featureless environment. This rig gives the
-- three shapes that reveal different failures, plus the bright/dark contrast
-- and long strip highlight that roughness and anisotropy need to be readable.

fn vrayMaterialLabTestRig =
	(
	local made = #()
	local lyr = undefined
	try
		(
		lyr = LayerManager.getLayerFromName "SB_MaterialTestRig"
		if lyr == undefined then lyr = LayerManager.newLayerFromName "SB_MaterialTestRig"
		) catch ()

	local sp = Sphere radius:20 segs:64 name:"SB_Test_Sphere" pos:[0,0,20]
	append made sp
	local cy = Cylinder radius:12 height:60 sides:64 name:"SB_Test_Cylinder" pos:[60,0,0]
	append made cy
	local bx = Box length:30 width:30 height:30 name:"SB_Test_BeveledCube" pos:[-60,0,0]
	try (addModifier bx (ChamferModifier())) catch ()
	append made bx
	-- Wedge: thin at one end, thick at the other, so absorption can be judged
	-- against thickness in a single object.
	local wd = Box length:20 width:80 height:24 name:"SB_Test_Wedge" pos:[0,70,0]
	try (addModifier wd (Taper amount:-1)) catch ()
	append made wd

	-- Two lights, because roughness and anisotropy need different cues: a large
	-- soft card shows reflection width, a long thin strip shows highlight
	-- stretch. Each is created separately so one failure does not lose both.
	local lightsOk = 0
	try
		(
		local key = VRayLight name:"SB_Test_KeyCard" type:0 size0:120 size1:120 multiplier:8
		try (key.transform = matrixFromNormal (normalize [1,1,-1])) catch ()
		key.pos = [-120, -120, 140]
		append made key
		lightsOk += 1
		) catch ()
	try
		(
		local strip = VRayLight name:"SB_Test_StripLight" type:0 size0:400 size1:8 multiplier:14
		try (strip.transform = matrixFromNormal (normalize [0,1,-1])) catch ()
		strip.pos = [0, -160, 180]
		append made strip
		lightsOk += 1
		) catch ()

	-- The dark card is what makes roughness width legible; a fully white studio
	-- flattens every metal.
	local neg = Box length:1 width:300 height:200 name:"SB_Test_NegativeFill" pos:[160,0,100]
	try
		(
		local blackM = VRayMtl name:"SB_Test_BlackCard"
		vMLSetAny blackM #("Diffuse") (color 4 4 4)
		vMLSetAny blackM #("Reflection") (color 0 0 0)
		neg.material = blackM
		) catch ()
	append made neg

	if lyr != undefined then (for o in made do (try (lyr.addNode o) catch ()))
	try (max zoomext all) catch ()

	local msg = (made.count as string) + " test objects created in layer SB_MaterialTestRig.\n\n" + \
		"Sphere: broad reflection behaviour\n" + \
		"Cylinder: anisotropy direction\n" + \
		"Beveled cube: edge response\n" + \
		"Wedge: thin-to-thick absorption\n" + \
		"Black card: the dark shape reflections need to read against"
	if lightsOk < 2 then msg += "\n\nOnly " + (lightsOk as string) + " of 2 V-Ray lights could be created - add a large area light and a long strip light manually."
	MessageBox msg title:"vrayMaterialLab"
	made.count
	)

-------------------------------------------------------------------------------
-- Notes
-------------------------------------------------------------------------------

fn vMLNotesText topic =
	(
	case topic of
		(
		1: #( \
			"METAL", \
			"", \
			"A conductor tints its reflection, not its diffuse.", \
			"Most manufactured metal shows more than one reflection scale:", \
			"  Lobe A  tight polished substrate", \
			"  Lobe B  broad manufacturing response, low blend amount", \
			"  Lobe C  directional machining, driven by anisotropy", \
			"A clear coat is a dielectric film above the metal, not a 2nd metal lobe.", \
			"Rust, dust, oxide and paint are separate dielectric substances.", \
			"Never represent rust by tinting a metal orange.", \
			"Keep secondary lobes subtle - stacked full-strength reflections", \
			"render brighter than real metal.", \
			"Judge metal against a dark card, never in a white studio." \
			)
		2: #( \
			"ABSORPTION", \
			"", \
			"Transmission follows T = e^(-sigma*d).", \
			"Double the thickness and the medium absorbs substantially more.", \
			"Colour therefore belongs in fog, not in the refraction tint.", \
			"Fog colour is subtractive: it is what survives the journey.", \
			"Fog depth is a physical distance - scene scale changes the result.", \
			"A shader built in centimetres misbehaves in a metre-scale scene.", \
			"Thin-walled or single-sided geometry has no thickness to absorb over.", \
			"A tail light needs several materials: clear cover, coloured lens,", \
			"reflector, and a real light source - not one emissive shell." \
			)
		3: #( \
			"ANISOTROPY", \
			"", \
			"Two separate controls: amount (how stretched) and direction (where).", \
			"A grayscale scratch texture carries no direction on its own.", \
			"Swirled machining needs a tangent field that rotates around a centre.", \
			"If bump scratches run circularly but anisotropy stays linear,", \
			"the shader contradicts itself.", \
			"Bump distorts reflections locally but is not a substitute for an", \
			"anisotropic BRDF - use both when the surface calls for it.", \
			"Scale the scratches to the object: macro bands, medium scratches,", \
			"micro polishing, sparse handling damage - not all at equal contrast.", \
			"Test anisotropy with a long rectangular light." \
			)
		4: #( \
			"IMPERFECTIONS", \
			"", \
			"Every mark should answer a physical question: was it touched,", \
			"wiped, machined, did dust settle, did water run down, did edges", \
			"contact something? Random noise is not material history.", \
			"Roughness carries most of the realism - fingerprints, oil, wiping,", \
			"thin dust and water spots change reflection before colour.", \
			"Colour variation stays subtle except for thick dirt, rust and stains.", \
			"Bump for shallow detail; displacement only when depth changes the", \
			"silhouette or produces parallax.", \
			"Keep bump frequency bands independent.", \
			"On coated surfaces, decide whether a defect is below the coat,", \
			"inside it, or a deposit above it - never apply one map to both.", \
			"Do not duplicate one texture across every channel." \
			)
		5: #( \
			"BUILD ORDER", \
			"", \
			"1. Correct geometry and bevels", \
			"2. Base material identity (conductor or dielectric, IOR)", \
			"3. Broad roughness response", \
			"4. Secondary reflection behaviour", \
			"5. Directional structure", \
			"6. Surface contamination", \
			"7. Micro bump / normal", \
			"8. Displacement only where silhouette or parallax needs it", \
			"", \
			"Do not begin by adding scratches.", \
			"Build the clean material first; add history afterwards.", \
			"Validate at final camera distance and output resolution." \
			)
		default: #("")
		)
	)

-------------------------------------------------------------------------------
-- Entry points
-------------------------------------------------------------------------------

fn vrayMaterialLab vMLRecipe vMLAssign =
	(
	if not (vMLVRayReady()) then return false
	vMLUnsetCount = 0
	local m = vMLBuildRecipe vMLRecipe
	if m == undefined then
		(
		MessageBox "Unknown recipe." title:"vrayMaterialLab"
		return false
		)
	local n = vMLAssignMtl m
	local msg = (vMLRecipeName vMLRecipe) + " built as " + m.name + \
		"\n\nPlaced in Material Editor slot " + (activeMeditSlot as string) + "."
	if n > 0 then msg += "\nAssigned to " + (n as string) + " object(s)."
	if vMLUnsetCount > 0 then msg += "\n\n" + (vMLUnsetCount as string) + " parameter(s) could not be written on this V-Ray version."
	MessageBox msg title:"vrayMaterialLab"
	true
	)

fn vrayMaterialLabDefaults =
	(
	vMLLoadDef()
	vrayMaterialLab vMLRecipeValue vMLAssignValue
	)

fn vrayMaterialLabUI =
	(
	vMLLoadDef()
	vMLCloseOpenUI vMLPosValue
	)

fn vMLCloseOpenUI pos =
	(
	if vMLFloater != undefined then (try (CloseRolloutFloater vMLFloater) catch ())
	vMLDefineUI()
	vMLFloater = newRolloutFloater "vrayMaterialLab v1.00" 330 660 pos.x pos.y
	addRollout vMLRecipeRollout vMLFloater
	addRollout vMLLobeRollout vMLFloater rolledUp:true
	addRollout vMLFogRollout vMLFloater rolledUp:true
	addRollout vMLAnisoRollout vMLFloater rolledUp:true
	addRollout vMLImperfRollout vMLFloater rolledUp:true
	addRollout vMLValidateRollout vMLFloater
	)

fn vMLHelp =
	(
	sLibSSPrintHelp "vrayMaterialLab"
	)

fn vMLLoadDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	vMLInputFilename = presetDir + "vrayMaterialLab.ini"
	if (sLibFileExist vMLInputFilename == true) then
		(
		vMLRecipeValue = sLibGetINIInteger vMLInputFilename "vrayMaterialLab" "vMLRecipeValue" 1
		vMLAssignValue = sLibGetINIBoolean vMLInputFilename "vrayMaterialLab" "vMLAssignValue" true
		vMLBaseRoughValue = sLibGetINIFloat vMLInputFilename "vrayMaterialLab" "vMLBaseRoughValue" 0.12
		vMLBroadRoughValue = sLibGetINIFloat vMLInputFilename "vrayMaterialLab" "vMLBroadRoughValue" 0.35
		vMLBroadAmountValue = sLibGetINIFloat vMLInputFilename "vrayMaterialLab" "vMLBroadAmountValue" 0.25
		vMLLobeAnisoValue = sLibGetINIFloat vMLInputFilename "vrayMaterialLab" "vMLLobeAnisoValue" 0.0
		vMLFogDepthValue = sLibGetINIFloat vMLInputFilename "vrayMaterialLab" "vMLFogDepthValue" 1.0
		vMLFogColorValue = sLibGetINIColor vMLInputFilename "vrayMaterialLab" "vMLFogColorValue" (color 190 30 30)
		vMLAnisoAmountValue = sLibGetINIFloat vMLInputFilename "vrayMaterialLab" "vMLAnisoAmountValue" 0.6
		vMLAnisoModeValue = sLibGetINIInteger vMLInputFilename "vrayMaterialLab" "vMLAnisoModeValue" 1
		vMLDustValue = sLibGetINIBoolean vMLInputFilename "vrayMaterialLab" "vMLDustValue" false
		vMLEdgeWearValue = sLibGetINIBoolean vMLInputFilename "vrayMaterialLab" "vMLEdgeWearValue" false
		vMLFingerprintValue = sLibGetINIBoolean vMLInputFilename "vrayMaterialLab" "vMLFingerprintValue" false
		vMLScratchValue = sLibGetINIBoolean vMLInputFilename "vrayMaterialLab" "vMLScratchValue" false
		vMLImperfAmountValue = sLibGetINIFloat vMLInputFilename "vrayMaterialLab" "vMLImperfAmountValue" 0.5
		vMLPosValue = sLibGetINIPoint2 vMLInputFilename "vrayMaterialLab" "vMLPosValue" (sLibGetSafeUIPos 330 660)
		)
	else
		(
		vMLRecipeValue = 1
		vMLAssignValue = true
		vMLBaseRoughValue = 0.12
		vMLBroadRoughValue = 0.35
		vMLBroadAmountValue = 0.25
		vMLLobeAnisoValue = 0.0
		vMLFogDepthValue = 1.0
		vMLFogColorValue = (color 190 30 30)
		vMLAnisoAmountValue = 0.6
		vMLAnisoModeValue = 1
		vMLDustValue = false
		vMLEdgeWearValue = false
		vMLFingerprintValue = false
		vMLScratchValue = false
		vMLImperfAmountValue = 0.5
		vMLPosValue = sLibGetSafeUIPos 330 660
		)
	)

fn vMLSaveDef =
	(
	presetDir = ((getdir #plugcfg) + "\\SoulburnScripts\\presets\\")
	if (getDirectories presetDir).count == 0 then makeDir presetDir
	vMLOutputFilename = presetDir + "vrayMaterialLab.ini"
	if (sLibFileExist vMLOutputFilename == true) then deleteFile vMLOutputFilename
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLRecipeValue" (vMLRecipeValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLAssignValue" (vMLAssignValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLBaseRoughValue" (vMLBaseRoughValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLBroadRoughValue" (vMLBroadRoughValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLBroadAmountValue" (vMLBroadAmountValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLLobeAnisoValue" (vMLLobeAnisoValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLFogDepthValue" (vMLFogDepthValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLFogColorValue" (vMLFogColorValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLAnisoAmountValue" (vMLAnisoAmountValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLAnisoModeValue" (vMLAnisoModeValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLDustValue" (vMLDustValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLEdgeWearValue" (vMLEdgeWearValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLFingerprintValue" (vMLFingerprintValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLScratchValue" (vMLScratchValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLImperfAmountValue" (vMLImperfAmountValue as string)
	setINISetting vMLOutputFilename "vrayMaterialLab" "vMLPosValue" (vMLFloater.pos as string)
	)

-- UI

fn vMLDefineUI =
	(
	rollout vMLRecipeRollout "Recipes"
		(
		dropdownlist vMLRecipeDropdown "" width:300 pos:[5,5] \
			items:#("Polished Steel", "Brushed Aluminum", "Rough Cast Metal", \
				"Chrome", "Gold", "Rusted Iron (Blend)", "Car Paint + Clear Coat", \
				"Clear Glass", "Red Tail-Light Lens", "Water", "Blood", \
				"Fingerprinted Black Plastic", "Dusty Metal (Blend)") \
			selection:vMLRecipeValue
		label vMLRecipeLabel (vMLRecipeInfo vMLRecipeValue) width:300 height:32 pos:[5,32]
		checkbox vMLAssignCheckbox "Assign to selected objects" checked:vMLAssignValue pos:[5,68]
		button vMLBuildButton "Build + Assign" width:150 pos:[5,88] toolTip:"Build the recipe and put it in the active Medit slot"
		button vMLHelpButton "Help" width:70 pos:[160,88]
		button vMLSaveDefButton "SaveDef" width:70 pos:[234,88]

		on vMLRecipeDropdown selected i do
			(
			vMLRecipeValue = i
			vMLRecipeLabel.text = vMLRecipeInfo i
			)
		on vMLAssignCheckbox changed s do vMLAssignValue = s
		on vMLBuildButton pressed do vrayMaterialLab vMLRecipeValue vMLAssignValue
		on vMLHelpButton pressed do vMLHelp()
		on vMLSaveDefButton pressed do vMLSaveDef()
		)

	rollout vMLLobeRollout "Metal Lobes"
		(
		label lbl1 "One roughness value cannot describe a machined metal." width:300 pos:[5,5]
		spinner vMLBaseRoughSpinner "Sharp lobe roughness: " range:[0.0,1.0,vMLBaseRoughValue] type:#float fieldWidth:55 pos:[5,25]
		spinner vMLBroadRoughSpinner "Broad lobe roughness: " range:[0.0,1.0,vMLBroadRoughValue] type:#float fieldWidth:55 pos:[5,46]
		spinner vMLBroadAmountSpinner "Broad lobe amount:    " range:[0.0,1.0,vMLBroadAmountValue] type:#float fieldWidth:55 pos:[5,67]
		spinner vMLLobeAnisoSpinner "Directional lobe aniso: " range:[0.0,1.0,vMLLobeAnisoValue] type:#float fieldWidth:55 pos:[5,88]
		label lbl2 "Keep the broad amount low - stacked full strength" width:300 pos:[5,110]
		label lbl3 "reflections render brighter than real metal." width:300 pos:[5,124]
		button vMLLobeButton "Build Multi-Lobe Metal" width:200 pos:[5,144]

		on vMLBaseRoughSpinner changed v do vMLBaseRoughValue = v
		on vMLBroadRoughSpinner changed v do vMLBroadRoughValue = v
		on vMLBroadAmountSpinner changed v do vMLBroadAmountValue = v
		on vMLLobeAnisoSpinner changed v do vMLLobeAnisoValue = v
		on vMLLobeButton pressed do
			(
			if (vMLVRayReady()) then
				(
				local m = vMLBuildLobeMetal vMLBaseRoughValue vMLBroadRoughValue vMLBroadAmountValue vMLLobeAnisoValue
				local n = vMLAssignMtl m
				local msg = "Multi-lobe metal built as " + m.name + "\n\nSharp " + \
					(vMLBaseRoughValue as string) + " / broad " + (vMLBroadRoughValue as string) + \
					" at " + (vMLBroadAmountValue as string) + " blend."
				if vMLLobeAnisoValue != 0.0 then msg += "\nDirectional lobe added at aniso " + (vMLLobeAnisoValue as string) + "."
				if n > 0 then msg += "\nAssigned to " + (n as string) + " object(s)."
				if vMLUnsetCount > 0 then msg += "\n\n" + (vMLUnsetCount as string) + " parameter(s) could not be written on this V-Ray version."
				MessageBox msg title:"vrayMaterialLab"
				)
			)
		)

	rollout vMLFogRollout "Absorption"
		(
		label lbl1 "Colour must come from distance travelled, not a tint." width:300 pos:[5,5]
		button vMLMeasureButton "Measure Selection" width:140 pos:[5,25] toolTip:"Read the smallest bounding box axis of the selection"
		spinner vMLFogDepthSpinner "Depth: " range:[0.0001,1000000,vMLFogDepthValue] type:#float fieldWidth:70 pos:[150,28]
		colorpicker vMLFogColorPicker "Fog colour: " color:vMLFogColorValue pos:[5,52]
		button vMLApplyFogButton "Apply Fog" width:140 pos:[5,78]
		button vMLWatertightButton "Check Watertight" width:140 pos:[150,78] toolTip:"Absorption needs a closed volume"
		label lbl2 "Depth is in scene units. A shader calibrated in cm" width:300 pos:[5,104]
		label lbl3 "will be wrong in a metre-scale scene." width:300 pos:[5,118]

		on vMLMeasureButton pressed do
			(
			local t = vMLMeasureThickness()
			if t != undefined then
				(
				vMLFogDepthValue = t
				vMLFogDepthSpinner.value = t
				MessageBox ("Measured thickness: " + (t as string) + " scene units.\n\nThis is the smallest bounding box axis of the selection - a reasonable proxy for how far a ray travels through the volume.") title:"vrayMaterialLab"
				)
			)
		on vMLFogDepthSpinner changed v do vMLFogDepthValue = v
		on vMLFogColorPicker changed c do vMLFogColorValue = c
		on vMLApplyFogButton pressed do vMLApplyFog vMLFogDepthValue vMLFogColorValue
		on vMLWatertightButton pressed do vMLCheckWatertight()
		)

	rollout vMLAnisoRollout "Anisotropy"
		(
		label lbl1 "Anisotropy needs an amount and a direction." width:300 pos:[5,5]
		spinner vMLAnisoAmountSpinner "Amount: " range:[-1.0,1.0,vMLAnisoAmountValue] type:#float fieldWidth:60 pos:[5,25]
		radiobuttons vMLAnisoModeRadio "Direction:" labels:#("Linear brushing", "Swirl (radial sanding)", "Lathe (turned part)") default:vMLAnisoModeValue columns:1 pos:[5,50]
		button vMLAnisoApplyButton "Apply Anisotropy" width:140 pos:[5,120]
		button vMLAnisoUVWButton "Add Matching UVW" width:140 pos:[150,120] toolTip:"Add and fit a UVW Map suited to the chosen direction"
		label lbl2 "Bump grooves and reflection stretch must agree," width:300 pos:[5,146]
		label lbl3 "or the surface contradicts itself." width:300 pos:[5,160]

		on vMLAnisoAmountSpinner changed v do vMLAnisoAmountValue = v
		on vMLAnisoModeRadio changed s do vMLAnisoModeValue = s
		on vMLAnisoApplyButton pressed do vMLApplyAnisotropy vMLAnisoAmountValue vMLAnisoModeValue
		on vMLAnisoUVWButton pressed do vMLAddUVWForAniso vMLAnisoModeValue
		)

	rollout vMLImperfRollout "Imperfections"
		(
		label lbl1 "Each cause gets its own map and its own channel." width:300 pos:[5,5]
		checkbox vMLFingerprintCheckbox "Fingerprints (roughness only)" checked:vMLFingerprintValue pos:[5,25]
		checkbox vMLScratchCheckbox "Micro-scratches (bump only)" checked:vMLScratchValue pos:[5,45]
		checkbox vMLEdgeWearCheckbox "Edge wear (blend + convex dirt)" checked:vMLEdgeWearValue pos:[5,65]
		checkbox vMLDustCheckbox "Dust (blend + gravity/cavity mask)" checked:vMLDustValue pos:[5,85]
		spinner vMLImperfAmountSpinner "Strength: " range:[0.0,1.0,vMLImperfAmountValue] type:#float fieldWidth:60 pos:[5,108]
		button vMLImperfButton "Add Layers" width:140 pos:[5,132]
		label lbl2 "Build the clean material first, then add history." width:300 pos:[5,158]

		on vMLFingerprintCheckbox changed s do vMLFingerprintValue = s
		on vMLScratchCheckbox changed s do vMLScratchValue = s
		on vMLEdgeWearCheckbox changed s do vMLEdgeWearValue = s
		on vMLDustCheckbox changed s do vMLDustValue = s
		on vMLImperfAmountSpinner changed v do vMLImperfAmountValue = v
		on vMLImperfButton pressed do
			(
			if (vMLVRayReady()) then
				vMLAddImperfections vMLDustValue vMLEdgeWearValue vMLFingerprintValue vMLScratchValue vMLImperfAmountValue
			)
		)

	rollout vMLValidateRollout "Validate"
		(
		button vMLAuditButton "Audit Materials" width:140 pos:[5,5] toolTip:"Flag physical mistakes in the selection, or the whole scene if nothing is selected"
		button vMLRigButton "Build Test Rig" width:140 pos:[150,5] toolTip:"Test shapes plus a high contrast light setup"
		dropdownlist vMLNotesDropdown "" width:150 pos:[5,32] items:#("Metal", "Absorption", "Anisotropy", "Imperfections", "Build order")
		button vMLNotesButton "Show Notes" width:140 pos:[150,32]

		on vMLAuditButton pressed do vrayMaterialLabAudit()
		on vMLRigButton pressed do
			(
			if (vMLVRayReady()) then vrayMaterialLabTestRig()
			)
		on vMLNotesButton pressed do
			vMLShowReport ("vrayMaterialLab - " + vMLNotesDropdown.selected) (vMLNotesText vMLNotesDropdown.selection)
		)
	)
)
-------------------------------------------------------------------------------
