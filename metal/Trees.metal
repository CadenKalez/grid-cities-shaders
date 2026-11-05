// =============================================================================
//  Trees.metal — vegetation pipeline, ported to Metal.
//
//  The engine draws trees in three tiers (material names from the shader table):
//    1. NonImpostorTree               — real meshes, close range (SH lit)
//    2. impostorTree                  — renders each tree model, from 8 view
//                                       angles, into an offscreen atlas:
//                                       colour, packed normal+depth, AO
//    3. treeParticleStandardCamFacing — camera-facing cards that sample the
//       treeParticleForestCamFacing     atlas.  "Forest" cards are generated
//                                       procedurally from the terrain eco map
//                                       (density), height map and normal map.
//  Plus treeBirth (grow-in animation) and tree shadow-map / deferred variants.
//
//  Original fragments: vs/0138 treeBirth, vs/0239..0245, ps/0346..0364
// =============================================================================
#include "Common.h"

// ---------------------------------------------------------------- constants --
constant float kTreeDirtPatchScale  = 3.0;
constant float kTreeShadowDarkening = 0.9;
constant float kStartFadeDistance   = 3000.0;
constant float kEndFadeDistance     = 3750.0;
constant float kNormalBias          = 0.45;
constant float kCliffCullingAngle   = 0.5;
constant float kTreeMinSize         = 0.3;
constant float kTreeMaxSize         = 0.9;
constant float kTreeSizeVary        = 0.05;
constant float kBeachTreeLine       = 8.5;     // trees stop 8.5 m above sea level
constant bool  kFixParallax         = true;
constant float kZBiasFactor         = -0.00001;
constant float kMipLevelClamp       = 5.0;

constant float2 vtxInfo[4] = { float2(0,0), float2(0,1), float2(1,1), float2(1,0) };

// ------------------------------------------------------------ uniform blocks --
struct ImpostorParticle {        // impostorParticles[64]
    float4 texXform;             // atlas uv origin (xy) and cell size (zw)
    float4 cardData;             // card corner offset (xy) and extent (zw), camera space
    float4 cardDepth;            // x: card depth offset, y: z-bias, z: depth range
};
struct TreeFrame {
    float4x4 cameraToClip;
    float3x4 worldToCamera;      // HLSL float4x3
    float3x4 modelToWorld;
    float4   worldCameraPosition;
    float4   worldCameraDirection;
    float4   gameInfo;           // x = game time (s)
    float4   screenInfo;         // zw = 1/target size
    float4   samplerInfo0;       // xy = atlas texture size
};
struct ForestInfoVS {            // terrainForestInfoVS
    float4 mWaterLevel;          // x = sea level
    float4 mTransform;           // xy = patch translation
    float4 mMapping;             // world xy -> map uv (scale xy, offset zw)
};
struct ForestHSV { float4 mHsvMin; float4 mHsvDiff; };   // terrainForestInfoPS[4]

struct TreeCardIn {
    float4 position [[attribute(0)]];   // modelPosition (forest: 0..1 patch coords)
    float3 normal   [[attribute(1)]];   // x: random/scale, y: model index, z: facing
    float2 uv0      [[attribute(2)]];   // x: corner index 0..3
    float4 color    [[attribute(3)]];   // rgb: HSV modifiers, a: sample index
};
struct TreeCardOut {
    float4 position [[position]];
    float4 t0;                           // uv, type/random
    float4 t1;                           // world position
    float4 color;
};

// --------------------------------------------------------------- helpers ----
// Wind sway, present in the shader but compiled out (`if(false)`) in shipping
// builds.  A travelling wave over x with a sqrt-eased sine and decaying envelope.
inline float3 CalculateTreeWindAnimation(constant TreeFrame& f, float2 animInfo) {
    const float kWaveLength = 10, kWaveZero = 5, kAnimSpeed = 1, kMaxAmplitude = 8;
    float wavePos   = f.gameInfo.x + animInfo.x * 0.005;
    float animTime  = fract(wavePos * (1.0 / (kWaveLength + kWaveZero)));
    float animScale = saturate(1.0 - animTime * ((kWaveLength + kWaveZero) / kWaveLength)) * kMaxAmplitude;
    animTime *= (kWaveLength + kWaveZero) * kAnimSpeed;
    float wave = sin(sqrt(animTime)) * animScale * animInfo.y;
    return xformDir(float3(-1, 0, 0), f.worldToCamera) * wave;
}

// Camera-space card expansion with a parallax correction: cards are offset in
// camera space, then the projected xy is rescaled so the card behaves as if it
// sat at the tree's centre depth (prevents cards "sliding" when the camera is
// steep).  Small depth bias per model keeps overlapping cards stable.
inline float4 CalculateFinalPosition(constant TreeFrame& f, float3 worldPos,
                                     float3 camOffset, float4 cardDepth) {
    float3 cPos = xform(float4(worldPos, 1), f.worldToCamera) + camOffset;
    float4 p    = float4(cPos, 1) * f.cameraToClip;
    if (kFixParallax) {
        float4 offW = float4(0, 0, 1, 0) * f.cameraToClip;
        p.xy -= p.w * offW.xy;
        p.xy *= p.w / (p.w - camOffset.z * offW.w);
        p.xy += p.w * offW.xy;
    }
    p.z += cardDepth.y * p.w * kZBiasFactor;
    return p;
}

inline float GetFadeValue(float3 worldPos, float3 camPos) {
    return saturate((length(worldPos - camPos) - kStartFadeDistance) /
                    (kEndFadeDistance - kStartFadeDistance));
}
inline float GetCameraDirFade(float3 camDir) {
    return saturate(dot(-camDir, float3(0, 0, 1)));   // 1 when looking straight down
}

// ============================================================================
//  1. Standard tree card (individually placed trees far from camera)
// ============================================================================
vertex TreeCardOut treeParticleStandardVS(TreeCardIn in [[stage_in]],
                                          constant TreeFrame& f            [[buffer(1)]],
                                          constant ImpostorParticle* imp   [[buffer(2)]]) {
    float2 quadCorner = vtxInfo[int(in.uv0.x)];
    float3 position   = in.position.xyz;
    float  direction  = in.normal.z;
    float  scale      = in.normal.x;
    int    modelIdx   = int(in.normal.y);
    ImpostorParticle P = imp[modelIdx];

    float3 camOffset = float3(P.cardData.xy + P.cardData.zw * quadCorner, P.cardDepth.x) * scale;
    TreeCardOut o;
    o.position = CalculateFinalPosition(f, position, camOffset, P.cardDepth);
    float4 tx  = P.texXform;
    tx.x += direction * tx.z;                       // pick the atlas column for this view angle
    float2 uv  = tx.xy + tx.zw * quadCorner;
    o.t0 = float4(uv.x, 1.0 - uv.y, quadCorner);
    o.t1 = float4(position, 1);
    o.color = in.color;
    return o;
}

// ============================================================================
//  2. Procedural forest card: the GPU decides per-vertex whether a tree exists.
//     treeParticleForestPosScale + treeParticleForestTransformVS
// ============================================================================
vertex TreeCardOut treeParticleForestVS(TreeCardIn in [[stage_in]],
                                        constant TreeFrame& f          [[buffer(1)]],
                                        constant ImpostorParticle* imp [[buffer(2)]],
                                        constant ForestInfoVS& forest  [[buffer(3)]],
                                        texture2d<float> heightMapVS   [[texture(0)]],
                                        texture2d<float> ecoMapVS      [[texture(1)]],
                                        texture2d<float> normalMapVS   [[texture(2)]]) {
    constexpr sampler lin(filter::linear, address::clamp_to_edge);
    float3 position    = in.position.xyz;
    float  sampleIndex = in.color.a;               // this card's slot in the density ramp
    float2 mapUV = position.xy * forest.mMapping.xy + forest.mMapping.zw;

    // terrain height (0..1 -> -1024..1024 m)
    float height  = heightMapVS.sample(lin, mapUV, level(0)).x * 2048.0 - 1024.0;
    // eco-map forest density: a card survives if density > its sample index
    float density = ecoMapVS.sample(lin, mapUV, level(0)).y;
    float size    = density - sampleIndex;
    // cliff culling from the terrain normal
    float3 n      = normalMapVS.sample(lin, mapUV, level(0)).xyz * 2.0 - 1.0;
    float3 flat   = normalize(float3(n.xy, 0.0));
    float  angle  = abs(dot(n, flat));
    float  seaLvl = forest.mWaterLevel.x + kBeachTreeLine;

    float drawQuad = (size <= 0.0) ? 0.0 : 1.0;    // 1) density
    drawQuad = (angle >= kCliffCullingAngle) ? 0.0 : drawQuad;   // 2) cliff
    drawQuad = (height < seaLvl) ? 0.0 : drawQuad; // 3) underwater / beach

    position.xy -= forest.mTransform.xy;
    position     = xform(float4(position, 1), f.modelToWorld);
    position.z   = height;
    float rnd    = fract(in.normal.x);
    float scale  = mix(kTreeMinSize, kTreeMaxSize, size) + rnd * kTreeSizeVary;

    // collapse culled quads to a degenerate point (drawQuad = 0)
    float2 origCorner = vtxInfo[int(in.uv0.x)] * drawQuad;
    float2 quadCorner = origCorner;
    int    modelIdx   = int(in.normal.y);
    ImpostorParticle P = imp[modelIdx];

    // flatten cards when seen from above and fade with distance
    float fade = 1.0 - GetFadeValue(position, f.worldCameraPosition.xyz);
    quadCorner.y *= saturate(GetCameraDirFade(f.worldCameraDirection.xyz) + fade);

    float3 camOffset = float3(P.cardData.xy + P.cardData.zw * quadCorner, P.cardDepth.x) * scale;
    TreeCardOut o;
    o.position = CalculateFinalPosition(f, position, camOffset, P.cardDepth);
    float4 tx = P.texXform;
    tx.x += in.normal.z * tx.z;
    float2 uv = tx.xy + tx.zw * origCorner;
    o.t0 = float4(uv.x, 1.0 - uv.y, in.normal.x, 0.0);   // z = tree type (floor) + random (frac)
    o.t1 = float4(position, 1);
    o.color = in.color;
    return o;
}

// ------------------------------------------------- shared card pixel stages --
struct CardSample { float4 diffuse; float4 normalDepth; float2 screenUV; };

inline CardSample treeParticleCommonSample(TreeCardOut in, constant TreeFrame& f,
                                           texture2d<float> sourceTex, texture2d<float> offscreenNormalTex) {
    constexpr sampler lin(filter::linear, mip_filter::linear, address::clamp_to_edge);
    CardSample s;
    s.screenUV = (in.position.xy + 0.5) * f.screenInfo.zw;
    float2 uv  = in.t0.xy;
    // manual LOD so the atlas cells don't bleed: log2 of the uv footprint, clamped
    float2 dx = dfdx(uv * f.samplerInfo0.xy), dy = dfdy(uv * f.samplerInfo0.xy);
    float mip = min(0.5 * log2(max(dot(dx, dx), dot(dy, dy))), kMipLevelClamp);
    s.diffuse = sourceTex.sample(lin, uv, level(mip));
    s.diffuse.a = saturate(s.diffuse.a * (1.0 / 0.9));
    s.diffuse.rgb /= max(s.diffuse.a, 1e-4);              // atlas is pre-multiplied
    float4 nm = offscreenNormalTex.sample(lin, uv, level(mip));
    nm.z /= max(nm.a, 1e-4);
    s.normalDepth = ImpostorUnpackNormalDepth(nm);
    return s;
}

// Forward-lit forest card (treeParticleForestCamFacing)
fragment float4 treeParticleForestPS(TreeCardOut in [[stage_in]],
                                     constant TreeFrame& f              [[buffer(1)]],
                                     constant ForestHSV* forestHSV      [[buffer(2)]],
                                     constant SunSkyInfo& sun           [[buffer(3)]],
                                     constant SunSkyRadianceScales& sc  [[buffer(4)]],
                                     texture2d<float> sourceTex          [[texture(0)]],
                                     texture2d<float> offscreenNormalTex [[texture(1)]],
                                     texture2d<float> skyTable           [[texture(11)]],
                                     texture2d<float> deferredLight      [[texture(12)]],
                                     texture2d<float> lightScalar        [[texture(13)]]) {
    CardSample s = treeParticleCommonSample(in, f, sourceTex, offscreenNormalTex);

    // per-species colour variation: 4 tree types, HSV range lerped by vertex colour
    int    treeType = clamp(int(floor(in.t0.z)), 0, 3);
    float3 hsv = forestHSV[treeType].mHsvMin.xyz + forestHSV[treeType].mHsvDiff.xyz * in.color.rgb;
    s.diffuse.rgb = CalculateHSVTweakedColor(hsv, s.diffuse.rgb);

    // alpha fade: distance + top-down view
    float distFade  = 1.0 - GetFadeValue(in.t1.xyz, f.worldCameraPosition.xyz);
    float alphaFade = saturate((1.0 - GetCameraDirFade(f.worldCameraDirection.xyz)) + distFade);

    constexpr sampler lin(filter::linear, address::clamp_to_edge);
    constexpr sampler pt (filter::nearest, address::clamp_to_edge);
    SkyResources   sky { skyTable, lin };
    LightingInputs li  { lightScalar, deferredLight, pt };
    float3 dif, spc, hi = 0; float shadow;
    // hard-coded "foliage" material: low gloss, broad weak highlight
    const float gloss = 0.08, specE = 3.0, specStrength = 0.2;
    SceneLighting(sky, li, sun, sc, s.screenUV, s.normalDepth.xyz,
                    f.worldCameraDirection.xyz, gloss, gloss, specE, specStrength,
                    dif, spc, hi, shadow);
    return float4(s.diffuse.rgb * (dif + spc) + hi, s.diffuse.a * alphaFade);
}

// Deferred variant (treeParticleCommonDeferredPS): writes packed depth and normal
struct TreeGBuffer { float4 depth [[color(0)]]; float4 normal [[color(1)]]; };
fragment TreeGBuffer treeParticleDeferredPS(TreeCardOut in [[stage_in]],
                                            constant TreeFrame& f [[buffer(1)]],
                                            texture2d<float> sourceTex          [[texture(0)]],
                                            texture2d<float> offscreenNormalTex [[texture(1)]]) {
    CardSample s = treeParticleCommonSample(in, f, sourceTex, offscreenNormalTex);
    float distFade  = 1.0 - GetFadeValue(in.t1.xyz, f.worldCameraPosition.xyz);
    float alphaFade = saturate((1.0 - GetCameraDirFade(f.worldCameraDirection.xyz)) + distFade);
    if (s.diffuse.a * alphaFade - 1.0 < 0.0) discard_fragment();  // only fully-opaque texels
    // per-pixel depth from the impostor: card depth + texel relief * depth range
    float outDepth = saturate(in.t0.x + s.normalDepth.w * in.t0.y);
    TreeGBuffer g;
    g.depth  = PackDepth24(outDepth, 8.0 / 255.0);
    g.normal = float4(s.normalDepth.xyz * 0.5 + 0.5, 1.0);
    return g;
}

// Tree shadow caster (treeParticleCommonShadow): reconstructs per-texel depth
struct TreeShadowOut { float4 color [[color(0)]]; float depth [[depth(any)]]; };
fragment TreeShadowOut treeParticleShadowPS(TreeCardOut in [[stage_in]],
                                            float4 projZ [[user(t2)]],   // xy + zw*relief
                                            texture2d<float> sourceTex [[texture(0)]]) {
    constexpr sampler lin(filter::linear, address::clamp_to_edge);
    float4 d = sourceTex.sample(lin, in.t0.xy);
    if (d.a < 0.333) discard_fragment();
    float2 pz = projZ.xy + projZ.zw * d.z;
    TreeShadowOut o;
    o.depth = saturate(pz.x / pz.y);
    o.color = 1.0;
    return o;
}

// ============================================================================
//  3. Impostor atlas generation (impostorTree material)
//     Renders the real tree mesh into atlas cell `angle` (0..7).
// ============================================================================
struct ImpostorAtlas {           // scImpostorAtlasPosition
    float4   projScale;          // w = leaves fallen (autumn / dead tree) threshold
    float4   projOffset;
    float4   scale[8];
    float4   offset[8];
    float4x4 transform[8];       // per-view rotation
};
struct ImpostorVIn {
    float4 position [[attribute(0)]];
    float3 normal   [[attribute(1)]];
    float3 tangent  [[attribute(2)]];
    float2 uv0      [[attribute(3)]];
    float2 uv1      [[attribute(4)]];
    float  angle    [[attribute(5)]];   // texcoord4.x * 255
};
struct ImpostorVOut {
    float4 position [[position]];
    float4 t0;     // uv0, uv1 (AO)
    float4 t1;     // normalised cell clip pos (xyz) + leavesFallen
    float4 t2;     // normal + leavesFallen
    float4 t3;     // tangent
};
vertex ImpostorVOut impostorTreeVS(ImpostorVIn in [[stage_in]],
                                   constant ImpostorAtlas& A   [[buffer(1)]],
                                   constant float3x4& worldToCamera [[buffer(2)]]) {
    int angle = int(in.angle * 255.0 + 0.5);
    float leavesFallen = A.projScale.w;
    ImpostorVOut o;
    o.t0 = float4(in.uv0 + float2(0, 1), in.uv1 + float2(0, 1));
    float3 p = (float4(in.position.xyz, 0) * A.transform[angle]).xyz;
    p = xform(float4(p, 0), worldToCamera);
    p = p * A.projScale.xyz + A.projOffset.xyz;      // normalise to [-1,1] cell space
    o.t1 = float4(p, 0);
    p = p * A.scale[angle].xyz + A.offset[angle].xyz; // place in the atlas
    o.position = float4(p, 1);
    o.t2 = float4((float4(in.normal, 0)  * A.transform[angle]).xyz, leavesFallen);
    o.t3 = float4((float4(in.tangent, 0) * A.transform[angle]).xyz, 0);
    return o;
}
struct ImpostorAtlasOut { float4 color [[color(0)]]; float4 normalDepth [[color(1)]]; };
fragment ImpostorAtlasOut impostorTreePS(ImpostorVOut in [[stage_in]],
                                         texture2d<float> diffuseTex [[texture(0)]],
                                         texture2d<float> normalTex  [[texture(1)]],
                                         texture2d<float> aoTex      [[texture(2)]]) {
    constexpr sampler s(filter::linear, mip_filter::linear, address::repeat);
    float3 clipPos = in.t1.xyz;
    if (any(float4(1 + clipPos.xy, 1 - clipPos.xy) < 0)) discard_fragment(); // keep to the cell
    float4 diffuse = diffuseTex.sample(s, in.t0.xy);
    float4 nmap    = normalTex.sample(s, in.t0.xy);
    float4 ao      = aoTex.sample(s, in.t0.zw);
    float  leavesFallen = in.t2.w;
    ImpostorAtlasOut o;
    o.color.rgb = diffuse.rgb * ao.rgb;
    // AO alpha doubles as a "leaf age" mask: leaves vanish where aoMap.a < leavesFallen
    o.color.a   = diffuse.a * saturate(100.0 * (ao.a - leavesFallen) + 1.0);
    o.color.rgb *= o.color.a;                                      // pre-multiply
    float3 bump = ApplyNormalMap(in.t2.xyz, in.t3.xyz, nmap.xyz * 2.0 - 1.0);
    o.normalDepth = float4(ImpostorPackNormalDepth(bump, clipPos.z), 1.0);
    return o;
}

// ============================================================================
//  4. treeBirth — newly planted trees grow: first the trunk extends vertically
//     (30 % of the time), then the crown widens from 10 % to full radius,
//     bottom-to-top.  Applied to Current.position in model space.
// ============================================================================
inline float3 TreeBirth(float3 p, float birthTime) {
    const float kAnimSpeed = 1.5, kTransitionSpeed = 2, kObjectHeight = 10, kVertFraction = 0.3;
    float t0 = kAnimSpeed * birthTime;
    float t1 = saturate(t0 / kVertFraction);
    float t2 = saturate((t0 - kVertFraction) / (1.0 - kVertFraction));
    float relZ = p.z / kObjectHeight;
    p.z  *= t1;
    p.xy *= 0.1 + 0.9 * saturate(kTransitionSpeed * ((relZ - 1.0) + 2.0 * t2));
    return p;
}

// ============================================================================
//  5. Terrain under forests (terrainPS forest branch): darken ground beneath
//     the canopy with a sun-offset lookup of the forest mask = cheap canopy shadow.
// ============================================================================
inline float ForestGroundShadow(texture2d<float> forestColorMap, sampler s,
                                float2 heightMapUV, float3 sunDir) {
    float2 forestMapOffset = normalize(sunDir.xy) * 0.0025;
    float mask = forestColorMap.sample(s, heightMapUV + forestMapOffset).a;
    return 1.0 - mask * kTreeShadowDarkening;
}
inline float TreeDirtPatch(float treeMask) {   // bare soil under trees reduces grass
    return saturate((1.0 - treeMask) * kTreeDirtPatchScale);
}
