# Week 3 — 3D Lighting Course
*Iván M. Benítez Sanz*

---

## Indirect Lighting (Global Illumination)

Indirect lighting, global illumination (GI), or indirect lights are the light bounces calculated by the rendering engine through a series of complex algorithms. This is computationally expensive, which is why noise in an image usually comes from indirect lighting and why it significantly increases render times.

We can fake these bounces by adding lights manually, reducing dependence on GI and allowing us to lower sample counts to save render time.

---

## Pros and Cons of GI

**Pros**
- More realistic finish due to Physically Based Rendering (PBR) — illuminates in a physically accurate way.
- No need to worry about the colour tone or intensity of bounces; the engine handles it automatically.

**Cons**
- More expensive to work with in real time; seeing changes instantly is harder.
- Requires a good computer to get the most out of it.
- Noise is not difficult to eliminate, but doing so is expensive — render times increase significantly.

---

## So, Is It Worth Using GI?

Yes. With GI you obtain much better, more realistic and cleaner images. It is a matter of finding a balance between lighting quality and render times, which is why it is extremely important to learn the render settings and the different sample controls.

The quickest way to detect the source of noise in a render is to examine the different AOVs — this shows which samples should be increased and which can be lowered to save time. Rendering a single 4K image is very different from rendering a 600-frame HD animation; the latter can take days depending on the hardware.

---

## Bounces (Light Bounces)

If you do not want to depend entirely on GI, you can fake light bounces manually — for example, to illuminate a character with a bounce light.

> **Important:** Light bounces are diffuse, so they have no directionality and produce very soft shadows. For this reason the light spread should be left at **1**.

---

## AOVs (Arbitrary Output Variables)

AOVs are render passes. When combined they form the **beauty pass** (e.g. diffuse, specular, SSS). There are also **utility passes** used for compositing changes (normals, UVs, depth, etc.).

AOVs give more compositing control over the final image — allowing you to edit specular, diffuse, and other components separately. They can be combined into a single EXR file using the **Merge AOVs** option in the render settings.

---

### Diffuse

The diffuse pass shows the colour of scene elements without shadows, highlights, specular, SSS, or any editing — it is the base colour of the shaders. Skin with subsurface scattering will look unusual in this pass because SSS is excluded.

---

### Specular

The specular pass shows the reflections of objects. It can be used in compositing to reduce or increase the apparent reflectivity of a surface.

---

### Subsurface Scattering (SSS)

SSS is (arguably) one of the most difficult shader attributes to configure, but also one of the most impactful for realism. It is used on skin, leather, plastics, silicone, and similar surfaces. Light penetrates the surface of an object and exits at a different point, producing the characteristic reddish glow visible through thin areas like fingers, nose, and ears.

---

### Emission / Volumetric

The emission pass contains objects with emissive shaders (via the emission attribute) as well as volumetrics. Because volumetrics are included here, it is sometimes necessary to use render layers to separate them.

---

### Beauty

The beauty pass is the final composited pass with all AOVs joined — the raw render before compositing. It is the final image as it comes out of the renderer.

---

### Light Groups

Light groups are AOVs for individual lights. They are set up in the **AOV Light Group** section of the light's visibility settings. A new AOV is then created — for example `RGBA_key` — and specific AOVs per group can be created the same way (e.g. `Diffuse_key`, `Specular_key`).

---

### Depth (Z Pass)

The depth or Z pass is used to create compositing masks (useful for separating foreground, midground, and background) or for depth-of-field blurring using a ZDefocus or pgBokeh node. It masks objects according to their distance from the camera. The Z depth can be modified in compositing to create FG, MG, or BG masks.

---

### Position (P Pass)

The Position AOV uses the position of assets relative to world space to create masks in compositing. There is also a **Pref (Position Reference)** variant.

In a standard world Position pass, colours change as the character moves through space. In a **Pref** pass this does not happen, making it possible to create a mask that follows a character even when it moves — very useful for creating eye specs or eye highlights.

---

### UVs

The UV AOV shows the UV coordinates of each object. Like the Normals pass, it is output through an `aiUtility` node in the shader using **UV Coords** colour mode. It can be used to project textures onto geometry in compositing.

---

### Normal (N Pass)

The Normals AOV is a map of the face orientations of the geometry. It can be used, for example, to perform a relight in Nuke.

---

## Light Filters

Light filters are additions attached to individual lights to modify them. Each light type supports certain filters only (e.g. the Gobo is only available for spot lights).

| Filter | Description |
|---|---|
| **Light Blocker** | Creates a bounding box (cube, sphere, plane, etc.) that blocks light within or outside that volume. Can be inverted so light only affects inside the box. Not very commonly used. |
| **Light Decay** | Controls when the light fades — both near decay and far decay. Normally left at quadratic, following the inverse square law: rays disperse and lose intensity as they move away from the source. |
| **Gobo** | An image projected through a light to fake shadows — for example, casting tree shadow patterns. Common in theatre. Set the image in **Slide Map**; filter mode controls blending, and density controls opacity. |
| **Barndoor** | Focuses the light onto a specific area using adjustable "fins" on the sides of the light. Only available for spot lights. |

---

# The Lighting in Photorealism — 10 Points
*Ciro Sannino — Chaos Mentor & Official Corona/V-Ray Instructor*

> Valid for Corona, V-Ray, and any physically based renderer in any 3D software.

---

## Point 1 — Why Don't Lighting Libraries Exist?

There are libraries for almost everything in the rendering world: textures, objects, vegetation, materials. But there is no established "Lighting Library." Attempts have been made — including preset CGI photographic sets — but even a small change renders the whole set unusable.

There is also no dedicated control panel for lighting. We have the material editor, the render setup, per-light controls, and the Light Lister — but no lighting panel.

The reason is simple: **lighting is not an asset.** It is the element that brings everything together, interacting with three main components simultaneously: the lights, the framing angle, and the objects. A lighting setup is inseparable from the specific scene and camera angle it was built for.

---

## Point 2 — The Real Lighting Problem

Lighting is ubiquitous and intangible at the same time, which is why so little material about it exists online. It is easy to focus on concrete parameters like the material editor or render setup. Managing the element that ties everything together is much harder.

In Archviz, artists spend many hours on the same image. This prolonged immersion leads to **visual habituation** — the inability to see mistakes or areas of improvement. This makes it crucial to anchor your work to classic rules, methods, and techniques of lighting rather than relying on subjective perception alone.

---

## Point 3 — Origin and Meaning of Lighting

Lighting in rendering is not simply turning on the lights so you can see the scene. Like Renaissance painting or photography, it is not only meant to make the scene visible.

Despite working in a three-dimensional space, **the final render is always a two-dimensional image** — just like a painting or a photograph. For this reason, lighting is the *generative mother of the third dimension*. This approach descends from the Italian Renaissance, when paintings became photorealistic through the mastery of light and shadow — an approach later inherited by photography.

Lighting can be structured in layers:

- **Primary light** — defines the main direction of light in the scene, establishes shadow orientation, and determines the overall look.
- **Secondary / Fill light** — softly illuminates shadowed areas, reduces harsh contrast, and reveals detail that would otherwise be lost.
- **Accent lights** — bright spots that add energy to the image; they do not produce general illumination but highlight specific features or create reflections.

This **hierarchy of lights** applies to any lighting setup, simple or complex. It is not just a way to organise lighting; it guides reasoning and counteracts visual habituation by providing an objective framework to evaluate the render.

> **Archviz note:** Soft images — gradual, blended transitions between lights and shadows rather than harsh contrasts — are a fundamental goal in architectural visualisation.

---

## Point 4 — Structure

Reading the light structure in a render is a valuable exercise, especially on clay renders (uniformly grey, no texture). Look for:

- **White arrows** → Primary: natural light (sun + sky enveloping the scene)
- **Black arrows** → Secondary: spotlights and directed fills
- **Red circles** → Accents

Each shape in the scene should be modelled by gradients and tonal steps — this is what separates a flat render from a photographic one.

---

## Point 5 — Theory and Self-Learning

Learning structured lighting schemes offers significant advantages over ad hoc approaches:

- It speeds up execution.
- It makes optimisation and problem-solving faster.
- It enables professional reviews — a valuable skill for supervisors in Archviz.

The musical parallel: great jazz musicians who can reinterpret Bach in Jazz are also flawless performers of the original piece. They improvise *because* they understand theory deeply. The same applies to lighting.

---

## Point 6 — Trial and Error?

Attempting to learn lighting purely through trial and error is neither efficient nor sustainable. It is like trying to reinvent mathematics without studying theory.

Studying the fundamental principles of photography and lighting is an investment that pays off long-term. It transforms lighting from a process of accidental discovery into one of **precision and intentionality**.

---

## Point 7 — Having No Limits Is a Limit Itself

In a real photographic set, limits exist naturally:
- A finite number of lights (usually two or three).
- Each light has a cost.
- Everything must be achieved with the minimum viable setup.

These constraints are a **natural teacher**. They force creative thinking: *What is the minimum setup needed to achieve this goal?* Essentiality becomes a strength. It focuses energy on what is truly important and prevents the confusing accumulation of lights that produces inconsistent, uncontrollable results.

---

## Point 8 — Limits to Implement (Three Photographic Constraints)

These are not rigid rules — they are habits that promote an ordered, consistent work style:

### 1. Avoid adding too many lights without a scheme
Do not insert lights indiscriminately. Add only the lights strictly necessary to establish the minimum hierarchy. In large-scale scenes, many lights may be needed — but each must have a specific role within the hierarchy. Lights exist to create **chiaroscuro and depth**, not simply to fill space.

### 2. Do not light with invisible lights
In a real photographic set, there are no invisible lights. Using invisible lights to *illuminate* (create shapes through chiaroscuro) introduces a percentage of a fake, inconsistent effect that is often imperceptible to the untrained eye but undermines photorealism. Invisible lights are acceptable only for silhouettes, reflections, or simulating the glow of self-illuminating objects that do not emit light.

### 3. Do not overly alter the sunlight
The sun's intensity multiplier defaults to 1.0 — leave it there. The sun in reality cannot be modified at will. If overexposure is a problem, manage it through **camera exposure**, different angles, or tone compression — not by turning down the sun. To simulate a slightly overcast sky: lower the multiplier *and* increase the size value (a larger solar disc = softer, more diffuse shadows).

> These constraints will not make you a rendering wizard on their own, but they will help you think like a real photographer and apply solutions that are replicable across similar contexts.

---

## Point 9 — Each Shot Has Its Own Lighting

Lighting is not a static element that can be reused across camera angles. Each shot, each perspective, requires unique lighting because **lighting is the primary tool for creating the third dimension in a 2D image**.

A professional photographer takes on average 45 minutes to set up lights for a single interior shot (including physical placement of equipment). In rendering, the physical effort is absent — but the creative challenge is identical.

For small movements or focal length changes, lighting variations may be minimal. But a complete change of viewpoint requires reviewing the entire lighting setup. Understanding this is particularly important for architects and designers working on multiple views of the same interior or exterior scene.

---

## Point 10 — "This Is Not a Pipe" (Ceci n'est pas une pipe)

Magritte's 1929 painting *La Trahison des Images* bears the inscription *"Ceci n'est pas une pipe"* — "This is not a pipe." His point: the representation of an object is not the object itself, but the artist's interpretation of it.

The same applies to architectural rendering. What you work on for hours is not the building — it is a two-dimensional representation of it. Despite working in 3D, the final product is always a flat image.

**Practical implication:** Do not try to imitate the real world directly. Instead, **study how photographs are made** and imitate those. Photorealism is not copying reality; it is your interpretation of reality through light, shadow, and composition — captured through a lens, even a virtual one.

**Recommended exercise:** Use a DSLR camera (even an inexpensive one) to develop compositional skills and light understanding separately from 3D software. Train your eye on photography, then bring that eye to rendering. Observe the world always through a lens.

---

## Conclusion

Lighting is not about placing a light source so you can "see" the scene. It is a **modelling process** accomplished with light — an art requiring deep understanding and careful manipulation to create a compelling image.

Lighting ties together composition, texture, geometry, and perspective. It is the glue binding all elements into a cohesive image. It is as much a creative act as a technical one.

This is why a lighting library cannot exist: while models, textures, and shaders are faithful representations of tangible reality, lighting is an art involving creativity, emotion, and the interaction of specific elements in a specific context. It must be studied and reviewed continually.

---

---

# 3ds Max Lighting — Reference Guide
*Nicholas Boughen — Wordware Publishing, 2005*

> A comprehensive reference covering lighting theory, 3ds Max lighting tools, and practical lighting design. The theory sections apply equally to any renderer or 3D application.

---

## Part I — Lighting Theory

### Chapter 1 — Properties of Light

Light has nine observable properties. Understanding each individually is the key to reading any lighting environment.

#### Intensity / Luminosity

- **Intensity** — the brightness of a light source (direct light from a spotlight, omni, or point light).
- **Luminosity** — the brightness of a *surface* (indirect light emitted by a material, e.g. a frosted bulb with radiosity enabled).

Intensity signals to the viewer what the light source is, even when it is not visible in frame.

#### Colour

Light colour is a visual key to mood and source. Common associations:
- **Blue/cool** → clear sky, shadows on a sunny day, somber/cold mood.
- **Amber/orange** → sun at golden hour, fireplace, warm mood.
- **Green** → eerie, unnatural, tension.
- **Pink/amber** → bright, happy setting.

Three distinct light sources typically produce three distinct colour ranges visible in a photograph. On a clear day: the sun (key, near-white/amber), the blue sky (fill from above, blue-tinted diffuse), and reflected ground light (amber fill from below).

> Note: Shadows on a clear sunny day appear blue because they are filled by skylight — a highly luminous, blue-tinted diffuse source.

#### Direction

Light direction establishes the source and creates emotional response:

- **High/overhead angle** → natural, familiar (sun, ceiling light).
- **Low angle from below** → strange, dramatic, frightening (the "flashlight under the chin" effect).
- **Steep and amber-white from above** → outdoor sunlight.
- **Ambient fill from all sides** → overcast, flat, no directional shadow.

The direction of shadows is the fastest way to read where the key light is in any image.

#### Diffuseness

Diffuse light has no single direction — it comes from many angles simultaneously. Examples: overcast sky, skylight, area lights, bounce light. Diffuse sources produce soft or no shadows. Specular/point sources produce hard, sharp shadows.

#### Shadow

Shadow is as important as light. It:
- Establishes depth and volume.
- Reveals the light source direction.
- Creates mood (deep shadows = drama; no shadows = flat/lifeless).

Shadow colour, density, and edge hardness are all controllable properties.

#### Shape

The shape of the light source determines the shape of highlights and softness of shadows. A small source produces a small, hard highlight. A large area source produces a broad, soft one.

#### Contrast

Contrast is the ratio between the brightest and darkest areas of the image. High contrast = dramatic. Low contrast = soft, Archviz-friendly. In Archviz, low to medium contrast with gradual light-to-shadow transitions is the default goal.

#### Movement

Animated or flickering light changes the entire emotional register of a scene. Even subtle light movement (a cloud passing, a candle) adds life.

#### Size

The size of the light source (not its brightness) controls shadow softness. Larger source = softer shadow edge (penumbra). Smaller source = harder shadow edge.

---

### Chapter 2 — What, Where, When?

Four context questions that must be answered before lighting a scene:

| Question | Variables |
|---|---|
| **Interior or Exterior?** | Controls light scale, bounce intensity, ambient level |
| **Time of Day** | Dawn/dusk = amber/orange, long shadows; midday = white, short shadows; night = artificial, high contrast |
| **Time of Year** | Sun elevation angle varies by season; winter = low sun even at midday |
| **Atmospheric Conditions** | Clear = hard shadows, blue sky fill; overcast = diffuse, no shadows; fog = soft, low contrast, distance haze |

---

### Chapter 3 — Light Sources

#### Sunlight
Near-parallel rays (the sun is 93 million miles away). Produces hard shadows. Colour ranges from blue-white (midday) to deep amber/red (golden hour). Use a Directional light in Max to simulate sunlight.

#### Skylight
The entire sky dome acts as a diffuse area light. Colour is blue on a clear day, grey on overcast days. The sky is the fill light in almost every exterior scene.

#### Incandescent Light
Warm, yellowish-orange. Attenuates with distance. Use a Point/Omni light or Photometric light in Max.

#### Fluorescent Light
Cool, slightly blue-green. Nearly no falloff over short distances. Common in office/commercial interiors.

#### Reflected / Diffuse Reflected Light
Indirect bounced light. Colour is tinted by the surface it bounced from (a red wall creates a red fill bounce). This is what GI calculates automatically.

> **Scale note:** Proportion and scale matter for attenuation. A light that looks correct at human scale will look wrong in an architectural scene if the scene units are off.

---

### Chapter 4 — Basic Material Considerations

Materials interact with light across four properties:

| Property | Description |
|---|---|
| **Specularity** | The brightness/tightness of the highlight. Metal = tight; matte = no specular. |
| **Glossiness** | Controls how blurry or sharp a reflection is. |
| **Reflectivity** | How much of the environment is reflected. |
| **Diffuse Colour** | The base colour of the material under neutral light. |
| **Luminosity** | Self-emission — contributes light to the scene under radiosity/GI. |

---

### Chapter 5 — Studying Light

#### Natural Light
- **Sunlight** → Near-white to amber. Hard shadows. Blue fill from sky.
- **Skylight** → Blue diffuse fill. Strengthens in clear weather.
- **Cloudy day** → Soft, directionless, grey-white. No shadows. Low contrast.
- **Moonlight** → Very dim. Blue-white. Hard shadows from a near-point source.
- **Starlight** → Practically no directional illumination.

#### Artificial Light
- **Incandescent** → Warm, attenuates, omni-directional.
- **Diffuse sources** → Softbox, panel — soft shadows, area light behaviour.
- **Point sources** → Bare bulb — hard shadows, omni-directional.
- **Fluorescent** → Cool, even, low falloff.

#### Shadow colour
On a sunny day, shadow colour = the colour of the fill source filling the shadow (blue sky = blue-tinted shadows). Shadow colour is not absence of colour; it is the colour of whatever is illuminating the shaded area.

---

### Chapter 6 — Principles of Lighting

#### The Hierarchy

| Role | Description |
|---|---|
| **Key light** | Primary, dominant source. Establishes main shadow direction and overall look. |
| **Fill light** | Softens shadows cast by the key. Reduces contrast. Usually dimmer and less saturated than the key. |
| **Highlight / Rim light** | Back or edge light. Separates the subject from the background. Creates a rim of light around the silhouette. |

#### McCandless Lighting
A classical theatrical method: two lights at 45° from the subject and 45° elevation, in complementary colours. Produces dimensional, even illumination with controlled colour.

#### Three-Point Lighting
The industry-standard method:
1. **Key** — 45° horizontal, 45° elevation, camera left or right.
2. **Fill** — opposite side to key, lower intensity (ratio typically 2:1 to 4:1 key:fill).
3. **Back/Rim** — behind the subject, above.

**Pros:** Creates clear separation, depth, dimension. Easy to set up. Teachable.
**Cons:** Can look formulaic and artificial if applied without adaptation.

#### Four-Point Lighting
Three-point + a **background light** to separate subject from background and add depth to the environment.

#### Complementary and Related Tints
- **Complementary tint** — key and fill are complementary colours (e.g. warm key / cool fill). Creates visual interest and depth.
- **Related tint** — key and fill are adjacent on the colour wheel. More harmonious, less dramatic.

#### Intensity Ratios
The ratio of key-to-fill determines contrast:
- 2:1 → low contrast, soft, Archviz-friendly
- 4:1 → medium contrast, photographic
- 8:1+ → high contrast, dramatic/cinematic

---

## Part II — 3ds Max Lighting Tools

### Chapter 7 — Standard Lights

| Type | Description |
|---|---|
| **Default Light** | Auto-generated when no lights exist. Removed when a light is added. |
| **Ambient Light** | Flat, directionless fill. Raises the black level of the entire scene. Use sparingly — it destroys shadow depth. |
| **Directional Light** (Free/Target) | Parallel rays. Ideal for sunlight simulation. Cone controls the lit area. |
| **Spotlight** (Free/Target) | Cone-shaped beam. Hotspot = bright core; Falloff = soft edge. |
| **Omni Light** | Point source radiating in all directions. Simple, fast. Use for fill or practical light sources. |

**Directional light parameters:**
- `Hotspot/Beam` — the inner bright cone
- `Falloff/Field` — the outer soft edge of the cone
- `Overshoot` — projects light beyond the cone (no cutoff)
- `Circle/Rectangle` — cone shape

---

### Chapter 8 — mental ray Lights (Legacy)

| Type | Description |
|---|---|
| **mr Area Omni** | Omni light rendered as a physical area source (sphere, cylinder). Produces soft shadows. |
| **mr Area Spot** | Spotlight rendered as a physical area source. Parameters: Type, Radius/Height/Width, Samples. |

Higher samples = softer, higher quality shadows at the cost of render time.

---

### Chapter 9 — Photometric Lights

Physically accurate lights based on real-world intensity (candela, lumen, lux) and colour temperature (Kelvin).

| Type | Description |
|---|---|
| **Point Light** | Omnidirectional photometric source |
| **Area Light** | Rectangular or disc area source |
| **Linear Light** | Tube/strip light source |
| **IES Sun** | Photometric sun using IES distribution |
| **IES Sky** | Photometric skylight |
| **Daylight System** | Combined IES Sun + IES Sky, geographically accurate |

**Colour options:** Kelvin temperature slider, colour swatch, filter colour.
**Intensity units:** Candela (cd), Lumen (lm), Lux (lx).

**Exposure Control** must be enabled when using photometric lights — otherwise the physical intensity values will severely overexpose the render. Use the Logarithmic or Physical Camera exposure control.

---

### Chapter 10 — Other Lighting in Max

#### Light Tracer and Radiosity (Scanline)
Radiosity = full global illumination solution for the scanline renderer. Physically accurate indirect light, very slow. Light Tracer = faster approximate GI via Monte Carlo sampling. Both largely superseded by modern renderers (Arnold, V-Ray, Corona).

#### Caustics
Light focused by reflective or refractive surfaces (lens flares in water, light patterns through glass). Expensive. Use sparingly and only where physically motivated.

#### Volume Lights
Visible light beams — the "god ray" effect through fog, smoke, or dusty air. Set up via Environment & Effects. Apply to any light type.

#### Objects as Lights
Self-luminous geometry contributing to scene illumination via radiosity or GI. Model the physical light fixture, assign a self-illuminating material, enable GI. More physically accurate than placing a hidden omni inside an object.

#### Lens Flares
Generated by the Video Post filter or as atmosphere effects. Use sparingly — they quickly become clichéd. Good legitimate uses: simulating an anamorphic look, stylised sci-fi, adding a subtle glow to a practical light source to confirm its presence.

---

### Chapter 11 — Manipulating Lights

#### Creating and Selecting
Lights are created in the Create panel → Lights category. Target lights have two components (light + target) selectable independently. Use `H` (Select by Name) to manage lights in complex scenes.

#### The Light Viewport
Press `Shift+4` or use the viewport menu to look through any selected light. Navigate the viewport to aim the light directly. Light viewport navigation controls:
- **Dolly** — move light toward/away from target
- **Orbit/Pan** — rotate/slide the light around the target
- **Roll Light** — rotate around the aim axis
- **Hotspot/Falloff** — widen or narrow the cone

#### The Light Lister
`Tools > Light Lister` — spreadsheet view of all scene lights. Edit multiplier, colour, shadow on/off for multiple lights simultaneously. Essential for managing complex lighting setups.

---

### Chapter 12 — General Light Parameters

#### General Parameters Rollout
- **On/Off** — toggle the light without deleting it
- **Type** — swap between Spot, Direct, Omni without rebuilding
- **Targeted** — toggle target object
- **Shadows On/Off** — per-light shadow toggle
- **Shadow Type** — Shadow Map, Ray-Traced, Advanced Ray-Traced, Area Shadows
- **Exclude** — list of objects excluded from this light's illumination and/or shadow casting

#### Intensity / Colour / Attenuation
- **Multiplier** — brightness scalar
- **Colour Swatch** — light tint
- **Decay Type** — None, Inverse, Inverse Square (physically correct)
- **Near/Far Attenuation** — manual start/end distances for light falloff (useful for faking or controlling fill lights)

#### Advanced Effects
- **Contrast** — increases or decreases the contrast between diffuse and ambient areas
- **Soften Diffuse Edge** — softens the transition between lit and unlit faces
- **Diffuse/Specular toggles** — control whether the light affects diffuse, specular, or both independently
- **Ambient Only** — light contributes only to the ambient channel (raises black level locally)
- **Projector Map** — project a texture or image through the light (gobo equivalent)

---

### Chapter 13 — Shadow Types

| Type | Speed | Quality | Use Case |
|---|---|---|---|
| **Shadow Map** | Fast | Medium | General use; adjustable softness via Sample Range |
| **mr Shadow Map** | Medium | Medium-High | mental ray scenes |
| **Ray-Traced Shadows** | Slow | Sharp | Transparent/refractive objects; precise hard shadows |
| **Advanced Ray-Traced** | Medium | High | Soft ray-traced shadows with spread control |
| **Area Shadows** | Slow | High | Soft area-light shadows from standard lights |

**Shadow Map parameters:**
- `Size` — map resolution (higher = sharper, more memory)
- `Sample Range` — controls softness of shadow edge
- `Bias` — offsets the shadow to prevent self-shadowing artefacts

**Area Shadow parameters:**
- `Shadow Spread` — simulates a larger light source for softer shadows
- `Shadow Integrity` / `Shadow Quality` — accuracy vs. speed trade-off

---

### Chapter 14 — Radiosity (Legacy GI)

#### Radiosity
Full finite-element GI solution. Calculates diffuse inter-reflection between surfaces. Slow but physically accurate for diffuse-heavy interior scenes. Baked into mesh — requires re-solving after geometry changes. Largely replaced by modern path-traced renderers.

#### Light Tracer
Faster Monte Carlo GI. Better for exteriors and scenes with predominantly direct lighting. Works with Skylights. Less accurate than Radiosity for complex interior bounce.

#### mental ray Global Illumination
Photon map-based GI within the mental ray renderer. More accurate and faster than the scanline Radiosity solution for complex scenes. Set photon count and radius to balance quality and speed.

---

### Chapter 15 — Texture Baking and Light Painting

#### Texture Baking (`Render to Texture`)
Bakes lighting (direct + indirect) into texture maps for real-time use. Essential for:
- Game assets requiring pre-baked lightmaps
- Accelerating previews in complex scenes
- Archiving a lighting state before changes

Workflow: Select objects → `Render to Texture` → choose elements (LightingMap, CompleteMap, ShadowsMap) → render → apply baked maps.

#### Light Painting
Painting light and shadow directly onto textures in Photoshop or the viewport. Non-physically accurate but fast. Useful for small fixes, adding detail to flat renders, or creating stylised looks.

---

### Chapter 16 — Max Colour Selection Tools

| Model | Description |
|---|---|
| **RGB** | Red/Green/Blue sliders (0–255). Direct screen value control. |
| **HSV** | Hue/Saturation/Value. Most intuitive for tinting lights. |
| **HSB** | Hue/Saturation/Brightness. Equivalent to HSV in Max. |
| **HSW** | Hue/Saturation/Whiteness. |
| **Kelvin** | Colour temperature (photometric lights only). 1800K = candlelight; 5500K = daylight; 10000K = clear blue sky. |

**Kelvin + Filter Colour:** Kelvin sets the base colour temperature; Filter Colour tints the output further. Use Filter Colour to add creative gels over a physically accurate Kelvin source.

---

### Chapter 17 — HDRI and Caustics

#### What Is HDRI?
High Dynamic Range Image — a panoramic photograph with a full range of real-world luminance values (multiple stops of exposure baked in). Used to light scenes by projecting the HDRI onto a dome or environment sphere.

#### Why Use HDRI?
- Provides realistic lighting from a real-world environment.
- Contains both the bright sky/sun and the dim shadowed areas in a single image.
- Drives both diffuse GI and specular reflections.
- Dramatically reduces the need for manually placed fill lights.

#### Using HDRI in Max
1. Create a Sphere (Environment sphere) — very large, facing inward (`Flip Normals`).
2. Apply an HDR material to it — use the Bitmap loader with the `.hdr` or `.exr` file, set mapping to Spherical Environment.
3. Or use Environment & Effects (`8`) → Background map → HDR bitmap with Spherical mapping.
4. With mental ray: use the mr Physical Sky or a Bitmap in the Environment slot, enable Final Gather.

**LightGen:** Extracts dominant light sources from an HDRI and generates actual Max lights to match them — useful for getting physically motivated key and fill positions.

#### Caustics
Focused light through refractive or reflective surfaces. Requires a caustic-capable renderer (mental ray, V-Ray, Arnold). Enable per-light and per-object. Expensive — only enable where physically required (glass of water, pool bottom, lens).

---

### Chapter 18 — Rendering

#### Default Scanline Renderer
The legacy renderer. Fast. Does not support physical GI without Light Tracer/Radiosity add-ons. Tabs:
- **Common** — output resolution, frame range, output path
- **Renderer** — antialiasing, shadows, mapping
- **Render Elements** — diffuse, specular, shadow, reflection passes (equivalent to AOVs)
- **Raytracer** — reflection/refraction settings
- **Advanced Lighting** — enable Light Tracer or Radiosity

#### mental ray Renderer Panel
- **Renderer tab** — sampling, filtering, shadows, caustics
- **Indirect Illumination tab** — Final Gather (FG), Global Illumination (GI photon maps), caustics settings
- **Processing tab** — diagnostics, translator options
- **Render Elements tab** — equivalent to AOVs (beauty, diffuse, specular, reflection, refraction, shadow, depth, normal)

---

## Part III — Creating Lighting

### Chapter 19 — Intent and Purpose

Before placing a single light, answer: **What is the emotional intent of this shot?**

- **Pleasant scene** → warm, soft, low-contrast, amber-white key, diffuse fill.
- **Sad scene** → cool, desaturated, low intensity, blue-grey tones, flat light.
- **Frightening scene** → high contrast, unusual angles (from below), harsh shadows, unnatural colour.

**Chiaroscuro** — the use of strong contrasts between light and shadow to give the illusion of volume — is the primary tool for creating emotion and depth. Every light placement decision should be motivated by either the physical story of the scene or the emotional intent.

**Justifying choices:** Every light in the scene should have a *motivation* — a real or implied source within the story world. A light that cannot be justified by something in the scene (a window, a lamp, a fire) will look wrong even to an untrained eye.

---

### Chapter 20 — Colour Mixing

#### Additive vs. Subtractive Colour
- **Additive (light):** R + G + B = White. Mixing coloured lights produces lighter colours.
- **Subtractive (pigment):** C + M + Y = Black. Mixing pigments produces darker colours.
- In rendering, lights use **additive** mixing. Materials/textures use **subtractive** (pigment) colour logic.

#### Colour Harmonies

| Harmony | Description | Effect |
|---|---|---|
| **Monochromatic** | Single hue, varying saturation/value | Unified, calm |
| **Complementary** | Opposite colours on the wheel | High energy, contrast |
| **Split Complementary** | One colour + two adjacent to its complement | Balanced contrast |
| **Analogous / Related Tint** | Adjacent colours on the wheel | Harmonious, natural |
| **Triadic** | Three evenly spaced colours | Vibrant, complex |

#### Psychology of Colour
- **Warm (red, orange, yellow)** → energy, warmth, tension
- **Cool (blue, green, purple)** → calm, cold, sad, eerie
- **High saturation + high value** → energetic, aggressive
- **Low value** → heavy, dramatic
- **Low saturation** → flat, lifeless, or subtle/sophisticated

---

### Chapter 21 — Mood Setting

Five tools for controlling mood:

| Tool | How it works |
|---|---|
| **Angle and Shadow** | Low angle = dramatic. High angle = natural. No shadow = flat/safe. Deep shadows = tension. |
| **Contrast** | High contrast = drama. Low contrast = soft/safe/Archviz. |
| **Intensity** | Very bright = harsh/clinical. Very dim = intimate/mysterious. |
| **Motion** | Animated/flickering light adds life, instability, or danger. |
| **Weather** | Clear = hard shadows, blue fill. Overcast = flat, diffuse, melancholy. Fog = distance haze, mystery. |

---

### Chapter 22 — Style

- **Less is more** — a simple, well-motivated setup with two or three lights almost always beats an accretion of uncounted fill lights.
- **Consistency between shots** — lighting style should remain coherent across a sequence. Use the same general colour temperature, contrast level, and key direction unless the story demands a change.
- Style emerges from knowing the rules and choosing when to break them — not from ignoring them.

---

### Chapter 23 — Designing Lighting

A professional lighting design process:

#### 1. Script / Brief Analysis
- Understand the story, mood, and emotional purpose of the scene.
- Identify the time of day, season, weather, and interior/exterior context.
- List all motivated light sources present in the scene.

#### 2. Research
- **Historical** — what light sources existed in the depicted period?
- **Visual** — collect reference photographs and paintings.
- **Technical** — what renderer, what light types, what AOVs are needed?
- **Dramatic** — what emotional effect must the lighting achieve?

#### 3. Planning
- **Sketches / Lighting plots** — diagram the position, direction, and type of each light before opening the software.
- **Magic Sheet** — a one-page summary of all lights in the rig: name, type, colour, intensity, purpose.
- **Formal Lighting Schedule** — full list with technical parameters.

#### 4. Implementation
- **Block placement** — rough positions first, no fine-tuning.
- **Rough out** — get all lights in approximate positions.
- **Fine-tune** — adjust multipliers, colours, shadow softness.
- **Work with materials** — lighting and shading are interdependent; adjust both together.

#### 5. Evaluation
- **Balancing the scene** — does every area read correctly? Are there dead zones?
- **Focus and emphasis** — does the eye go where it should?
- **Designing with shadow** — shadows are as important as light; treat them deliberately.
- **Lighting a scene vs. lighting an object** — the background must also be lit; objects should not float.

#### Saving and Reusing Lighting Rigs
Group all lights and merge as a Max file or use the `Asset Library`. Document the rig with a magic sheet so it can be adapted rather than rebuilt.

---

### Chapter 24 — Identifying and Recreating Light Sources in a Plate

When compositing CG into live-action footage, the lighting must match the plate exactly.

#### Reading a Plate
1. Identify shadow direction → key light position.
2. Identify shadow hardness → key light size/distance.
3. Identify colour of lit areas → key light colour.
4. Identify colour of shadowed areas → fill light colour.
5. Count distinct shadow directions → number of key sources.

#### The Mirror Ball Technique
Place a chrome mirror ball and a grey matte ball on set. Photograph both under the production lighting:
- **Chrome ball** → shows the position and colour of all light sources as reflections (a map of the lighting environment).
- **Grey ball** → shows diffuse response — direction, intensity, and colour of the dominant key.

Use the chrome ball image as an HDRI or to place matching lights in Max.

#### Replicating a Light Source
1. Match light *type* (directional, area, point).
2. Match light *colour* (sample from the brightest specular highlight in the plate).
3. Match light *direction* (read from shadow angle in plate).
4. Match shadow *softness* (read from shadow edge penumbra width).
5. Adjust *intensity* until the CG element's exposure matches the plate.

> **Important:** Getting the colour mathematically perfect is not the compositor's job alone — the lighting artist must get it as close as possible before handoff. Close is achievable; perfect is compositing's responsibility.

---

### Chapter 25 — Lighting Setup Examples

#### Exterior Sunny Day

A progression of eight setups of increasing physical accuracy:

| Exercise | Setup | Notes |
|---|---|---|
| 1 | Direct Key + Ambient Fill | Fastest, least realistic. Raises black level globally. |
| 2 | Direct Key + Direct Fill | Second fill light. Better shadow depth than ambient. |
| 3 | Shadow Maps | Add shadow mapping to the key. Faster than ray-traced. |
| 4 | Area Shadows | Softer, more realistic shadow edges. Slower. |
| 5 | Skylight Fill | Replace fill light with a Skylight. More realistic sky contribution. |
| 6 | mental ray Area Lights | Area light key + mr GI. More physically correct highlights. |
| 7 | Photometric Lights | IES-based physically accurate intensity. Requires exposure control. |
| 8 | IES Sun + IES Sky | Full photometric daylight system. Most accurate. Slowest. |

#### Exterior with Radiosity
Full GI solution using the scanline Radiosity solver. Required for accurate interior-exterior transition scenes where outdoor light bounces through windows.

---
