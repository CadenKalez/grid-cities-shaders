// =============================================================================
//  GlobalIllumination.metal — the ambient / indirect lighting model.
//
//  The engine has no dynamic GI solver.  Indirect light is the sum of:
//   * Sky ambient: a 2-D LUT of Perez sky terms, sampled along a direction
//     blended between N and R by gloss (EnvLighting) — the high-quality path.
//   * SH ambient: 9-coefficient (and 16 for glossy) spherical harmonics,
//     CPU-projected from the same sky, evaluated per vertex — low-quality,
//     effects, trees near the camera.
//   * Directional AO + bounce volumes (AmbientOcclusion.metal).
//   * Deferred point/spot/line lights accumulated into a light buffer that
//     forward materials read back (GetDeferredLight) — "light pre-pass" style.
//
//  Reference: vs/0040 shLightingDiffSpec9, vs/0041 shLightingDiff9Apply,
//  ps/0017 shLightingApply, ps/0044-0049 scLighting*, ps/0411 globalLightsPF,
//  pointPF, materials globalLightsShader / pointShader / spotShader.
// =============================================================================
#include "Common.h"

// ------------------------------------------------------------ SH, per vertex --
struct SHFrame {
    float4x4 worldToClip;
    float4   worldCameraDirection;
    float4   shCoeffs[16];
    DirLight dirLightsWorld[1];
};
struct SHVIn  { float3 position [[attribute(0)]]; float3 normal [[attribute(1)]]; float4 color [[attribute(2)]]; };
struct SHVOut { float4 position [[position]]; float3 n; float3 shDiff; float3 shSpec; float4 color; };

vertex SHVOut shLightingDiffSpec9VS(SHVIn in [[stage_in]], constant SHFrame& f [[buffer(1)]]) {
    SHVOut o;
    o.position = float4(in.position, 1) * f.worldToClip;
    o.n = in.normal;
    SHDiffSpec9(f.shCoeffs, normalize(in.normal), f.worldCameraDirection.xyz, false, o.shDiff, o.shSpec);
    o.color = in.color;
    return o;
}

// SHLightingGlossy16: adds the cubic band per pixel along the reflection vector
fragment float4 shLightingGlossy16PS(SHVOut in [[stage_in]],
                                     constant SHFrame& f [[buffer(1)]],
                                     constant float4& materialParams [[buffer(2)]]) {
    float specE = materialParams.x, specStrength = materialParams.y, gloss = materialParams.w;
    float3 n = normalize(in.n);
    float3 r = reflect(f.worldCameraDirection.xyz, n);
    float3 shSpec = in.shSpec + SHEvalBand3(f.shCoeffs, r);
    float3 shDiff = in.shDiff * (1.0 - gloss);
    shSpec *= gloss;
    float3 c = in.color.rgb * (shDiff + shSpec);
    c += CalcBlinnPhongSpec(f.dirLightsWorld[0].mDir.xyz, f.worldCameraDirection.xyz, n, specE)
         * specStrength * f.dirLightsWorld[0].mColor.rgb;
    return float4(c, in.color.a);
}

// -------------------------------------------------------- forward composite --
struct SceneFrame {
    float4 screenInfo;
    float4 worldFarCorners[4];    // world-space far-plane corner rays
    float4 materialParams;        // specE, specStrength, bumpFactor, gloss
};
struct LitIn { float4 position [[position]]; float3 n; float4 color; };

// scLightingApply: per-pixel sky env + sun + light buffer
fragment float4 sceneLightingApplyPS(LitIn in [[stage_in]],
                                     constant SceneFrame& f              [[buffer(1)]],
                                     constant SunSkyInfo& sun            [[buffer(2)]],
                                     constant SunSkyRadianceScales& sc   [[buffer(3)]],
                                     texture2d<float> skyTable      [[texture(11)]],
                                     texture2d<float> deferredLight [[texture(12)]],
                                     texture2d<float> lightScalar   [[texture(13)]]) {
    constexpr sampler lin(filter::linear, address::clamp_to_edge);
    constexpr sampler pt (filter::nearest, address::clamp_to_edge);
    float2 uv = (in.position.xy) * f.screenInfo.zw;
    // view ray by bilinear interpolation of the 4 far-plane corners
    float3 v = normalize(mix(mix(f.worldFarCorners[1], f.worldFarCorners[0], uv.y),
                             mix(f.worldFarCorners[3], f.worldFarCorners[2], uv.y), uv.x).xyz);
    float specE = f.materialParams.x, specStrength = f.materialParams.y, gloss = f.materialParams.w;
    float3 d, s, h = 0; float shadow;
    SceneLighting(SkyResources{skyTable, lin}, LightingInputs{lightScalar, deferredLight, pt},
                  sun, sc, uv, normalize(in.n), v, gloss, gloss, specE, specStrength, d, s, h, shadow);
    return float4(in.color.rgb * (d + s + h), in.color.a);
}

// ------------------------------------------------ deferred light accumulation --
// G-buffer: normal.xyz + gloss (RGBA8), depth packed RGB8 + spec power (A)
struct DeferredFrame { float4 worldCameraPosition; };

struct PointLightOut {
    float4 position [[position]];
    float4 t0;     // screen uv * w, z = 1/(r^2) denom
    float4 color;  // diffuse colour
    float4 t2;     // camera->far ray * w, w = volumetric strength
    float4 t3;     // light pos relative to camera, w = falloff bias
    float  doubleSided;
};

fragment float4 pointLightPS(PointLightOut in [[stage_in]],
                             texture2d<float> normalSampler [[texture(14)]],
                             texture2d<float> depthSampler  [[texture(15)]]) {
    constexpr sampler pt(filter::nearest, address::clamp_to_edge);
    float2 uv  = in.t0.xy / in.t0.w;
    float3 ray = in.t2.xyz / in.t0.w;
    float4 nv  = normalSampler.sample(pt, uv);
    float4 dv  = depthSampler.sample(pt, uv);
    float3 n   = normalize(nv.xyz * 2.0 - 1.0);
    float  depth = UnpackDepth(dv);
    float3 dir = ray * depth;                       // camera-relative (precision!)
    float3 L   = in.t3.xyz - dir;
    float  d2  = dot(L, L);
    float  atten = saturate(in.t3.w - d2 * in.t0.z);   // 1 - d^2/r^2 style
    float  ndl = dot(n, normalize(L));
    ndl = mix(saturate(ndl), abs(ndl), in.doubleSided);  // foliage / signs lit both sides
    return float4(in.color.rgb * ndl * atten * atten, 0);
}

// globalLightsPF + parallelLight{N}ShadowApply: up to 4 extra directional
// "parallel" lights evaluated in a full-screen pass, one of them shadowed by
// the screen-space shadow term.
struct ParallelLight { float4 lightDir; float4 color; float4 level; float4 fillColor; float4 fillLevel; };
struct GlobalLightsFrame { float4 worldCameraPosition; ParallelLight parallel[4]; };
struct GLIn { float4 position [[position]]; float2 uv; float3 toFar; };

fragment float4 globalLightsPS(GLIn in [[stage_in]],
                               constant GlobalLightsFrame& f [[buffer(1)]],
                               texture2d<float> normalSampler [[texture(14)]],
                               texture2d<float> depthSampler  [[texture(15)]],
                               texture2d<float> lightScalar   [[texture(13)]]) {
    constexpr sampler pt(filter::nearest, address::clamp_to_edge);
    float4 nv = normalSampler.sample(pt, in.uv);
    float3 n  = normalize(nv.xyz * 2.0 - 1.0);
    float gloss = nv.w;
    float shadow = lightScalar.sample(pt, in.uv).x;
    float4 acc = 0;
    for (int i = 0; i < 4; ++i) {
        ParallelLight P = f.parallel[i];
        float ndl  = dot(n, P.lightDir.xyz);
        // key + opposing fill lobe (wrap)
        float3 c = P.color.rgb * saturate(ndl) * P.level.x + P.fillColor.rgb * saturate(-ndl) * P.fillLevel.x;
        acc.rgb += (i == 0 ? shadow : 1.0) * c;
    }
    acc.a = gloss;    // applyGlossPF: spec intensity carried in alpha
    return acc;
}
