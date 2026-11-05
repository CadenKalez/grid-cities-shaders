// =============================================================================
//  Common.h  —  Apple Metal port of the shared 
//  shader library: packing helpers, Perez sky model, SH lighting, the
//  SceneLighting() composite, directional-AO solid-angle math, HSV tweak.
//
//  Ported from the HLSL fragment library extracted from the game data package
//  (resource type 0x0469A3F7, group 0x40212002, quality level 3).
//  See ../extracted_hlsl/quality3/fragments/*  for the original sources.
//
//  Matrix convention used throughout the port
//  ------------------------------------------
//  D3D9 HLSL used row-vector maths:  p' = mul(p, M).  fxc packs matrices
//  column-major into constant registers, so the CPU side uploads the *columns*
//  of M.  In Metal a matrix is an array of columns and `v * M` is the
//  row-vector product (result[j] = dot(v, M[j])).  Therefore:
//        HLSL  mul(v, float4x4 M)   ->  Metal  v * M   (M : float4x4)
//        HLSL  mul(v, float4x3 M)   ->  Metal  v * M   (M : float3x4)
//  and the same constant-buffer bytes can be used unchanged.
// =============================================================================
#pragma once
#include <metal_stdlib>
using namespace metal;

// ----------------------------------------------------------------------------
//  Constant blocks (names match the original HLSL uniforms)
// ----------------------------------------------------------------------------
struct SunSkyInfo {              // HLSL: cSunSkyInfo sunSky
    float4 mPerezA;              //  .w = scatter strength (SceneDensity path)
    float4 mPerezB;              //  .w = base fog density
    float4 mPerezC;              //  .w = fog start distance
    float4 mPerezD;
    float4 mPerezE;
    float4 mInvDensity;          //  zenith xyY scale
    float4 mSunDir;              //  world-space, Z-up
    float4 mZenith;
    float4 mSunColor;
    float4 mSkyColorTuning;      //  x = luminance scale, y = saturation
    float4 mDynamicWeather;      //  density/falloff for two atmosphere layers
};

struct SunSkyRadianceScales {    // dequantisation range of the sky LUT
    float4 thetaMin, thetaMax, gammaMin, gammaMax;
};

struct DirLight { float4 mDir; float4 mColor; };

// ----------------------------------------------------------------------------
//  Small HLSL compatibility helpers
// ----------------------------------------------------------------------------
inline float4 greater_equal(float4 a, float b) { return float4(a >= float4(b)); }
inline float3 xform(float4 v, float3x4 m)     { return v * m; }   // mul(v, float4x3)
inline float4 xform(float4 v, float4x4 m)     { return v * m; }   // mul(v, float4x4)
inline float3 xformDir(float3 v, float3x4 m)  {                   // mul(v, (float3x3)M)
    return float3(dot(v, m[0].xyz), dot(v, m[1].xyz), dot(v, m[2].xyz));
}

// ----------------------------------------------------------------------------
//  G-buffer / shadow-map packing (D3D9 had no float render targets on min-spec,
//  so the engine packs 24-bit depth into RGB8 and normals+depth into RGBA8)
// ----------------------------------------------------------------------------
inline float UnpackDepth(float4 rgbaDepth) {
    return dot(rgbaDepth.xyz, float3(1.0, 1.0 / 255.0, 1.0 / (255.0 * 255.0)));
}
inline float4 PackDepth24(float d, float specPow01) {
    return float4(floor(d * 255.0) / 255.0, fract(d * 255.0),
                  fract(fract(d * 255.0) * 255.0), specPow01);
}
// shadow map colour encoding used by renderShadowMap / tree shadows
inline float4 EncodeShadowDepth(float depth) {
    return float4(depth, fract(depth * 256.0), depth, 1.0);
}
// Impostor normal + per-pixel depth in RGB8: xy = normal.xy, z = sign(n.z)*depth
inline float4 ImpostorUnpackNormalDepth(float4 s) {
    float2 nxy   = s.xy * 2.0 - 1.0;
    float  xyLen = dot(nxy, nxy);
    float  dzs   = s.z - 0.5;
    float  depth = abs(dzs * 2.0);
    float  zSign = (dzs >= 0.0) ? 1.0 : -1.0;
    return float4(nxy, zSign * sqrt(max(0.0, 1.0 - xyLen)), depth);
}
inline float3 ImpostorPackNormalDepth(float3 n, float pixelDepth) {
    n = normalize(n);
    float zSign = (n.z >= 0.0) ? 0.5 : -0.5;
    return float3(n.xy * 0.5 + 0.5, zSign * pixelDepth + 0.5);
}
inline float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmap) {
    float3 vn = normalize(vertNormal);
    float3 dt = normalize(cross(vn, vertDS));
    float3 ds = cross(dt, vn);
    return normalize(nmap.r * ds + nmap.g * dt + nmap.b * vn);
}

// ----------------------------------------------------------------------------
//  Perez / Preetham sky.  The shipping path uses a 2-D LUT ("skyTermTable",
//  sampler s11) holding the theta and gamma Perez terms, dequantised with
//  sunSkyRadianceScales and evaluated in CIE xyY, then converted to RGB.
// ----------------------------------------------------------------------------
constant float3 kXYZToR = float3( 2.80298,   -1.18735,  -0.437286);
constant float3 kXYZToG = float3(-1.07909,    1.97927,   0.0423073);
constant float3 kXYZToB = float3( 0.0746015, -0.248513,  1.08196);
constant bool   kAvoidDesaturation = true;

inline float3 xyYToXYZ(float3 c) { return float3(c.x, c.y, 1.0 - c.x - c.y) * c.z / c.y; }
inline float3 XYZToRGB(float3 x)  { return float3(dot(kXYZToR, x), dot(kXYZToG, x), dot(kXYZToB, x)); }

// analytic version (SkyColorTG, used when kUseSkyTable == false)
inline float3 SkyColorTG(constant SunSkyInfo& info, float cosTheta, float cosGamma, float gamma) {
    float3 xyY = (1.0 + info.mPerezA.xyz * exp(info.mPerezB.xyz / cosTheta)) *
                 (1.0 + info.mPerezC.xyz * exp(gamma * info.mPerezD.xyz) +
                        info.mPerezE.xyz * cosGamma * cosGamma);
    xyY *= info.mInvDensity.xyz;
    const float2 kWhite = float2(0.33333);
    xyY.xy = kWhite + (xyY.xy - kWhite) * info.mSkyColorTuning.y;
    xyY.z *= info.mSkyColorTuning.x;
    if (kAvoidDesaturation) xyY.z = saturate(xyY.z);
    return XYZToRGB(xyYToXYZ(xyY));
}

// LUT version. `s` selects one of 4 pre-convolved rows (0 = sharp .. 1 = diffuse)
inline float3 SkyColorTableCompressed(texture2d<float> table, sampler smp,
                                      constant SunSkyInfo& info,
                                      constant SunSkyRadianceScales& sc,
                                      float cosTheta, float cosGamma, float s,
                                      bool withTuning) {
    s = (0.5 + 3.0 * s) / 8.0;
    float c = 0.5 * (cosTheta + 1.0);
    float g = sqrt(0.5 * (1.0 - cosGamma));
    float3 thetaTerm = mix(sc.thetaMin.xyz, sc.thetaMax.xyz, table.sample(smp, float2(c, s)).xyz);
    float3 gammaTerm = mix(sc.gammaMin.xyz, sc.gammaMax.xyz, table.sample(smp, float2(g, 0.5 + s)).xyz);
    float3 xyY = (1.0 + thetaTerm) * (1.0 + gammaTerm);
    xyY *= info.mInvDensity.xyz;
    if (withTuning) {
        const float2 kWhite = float2(0.33333);
        xyY.xy = saturate(kWhite + (xyY.xy - kWhite) * info.mSkyColorTuning.y);
        xyY.z *= info.mSkyColorTuning.x;
    }
    if (kAvoidDesaturation) xyY.z = saturate(xyY.z);
    return XYZToRGB(xyYToXYZ(xyY));
}

struct SkyResources {
    texture2d<float> skyTable;      // s11
    sampler          smp;
};

inline float3 SkyColor(SkyResources sky, constant SunSkyInfo& info,
                       constant SunSkyRadianceScales& sc, float3 v) {
    return SkyColorTableCompressed(sky.skyTable, sky.smp, info, sc,
                                   saturate(v.z), dot(info.mSunDir.xyz, v), 0.0, true);
}
// "Conv" = convolved: s picks a blurrier row, i.e. a cheap glossy pre-filter
inline float3 SkyColorConv(SkyResources sky, constant SunSkyInfo& info,
                           constant SunSkyRadianceScales& sc, float3 v, float s) {
    return SkyColorTableCompressed(sky.skyTable, sky.smp, info, sc,
                                   v.z, dot(info.mSunDir.xyz, v), s, false);
}

// ----------------------------------------------------------------------------
//  Specular models
// ----------------------------------------------------------------------------
inline float CalcBlinnPhongSpec(float3 L, float3 viewDir, float3 n, float e) {
    float3 h = normalize(L - viewDir);
    return pow(saturate(dot(n, h)), max(e, 0.001));
}
// normalised Blinn-Phong * Schlick Fresnel (exp2 approximation of pow5)
inline float CalcBlinnPhongSchlick(float3 L, float3 viewDir, float3 n, float e, float F0) {
    float3 h   = normalize(L - viewDir);
    e          = max(e, 0.001);
    float spec = pow(saturate(dot(n, h)), e);
    float norm = (e + 2.0) / 8.0;
    float F    = F0 + (1.0 - F0) * exp2(-8.656170 * saturate(dot(L, h)));
    return spec * norm * F;
}

// ----------------------------------------------------------------------------
//  Image-based "sky" ambient: one LUT lookup along a direction blended between
//  the normal and the reflection vector by glossiness.
// ----------------------------------------------------------------------------
inline void EnvLighting(SkyResources sky, constant SunSkyInfo& info,
                        constant SunSkyRadianceScales& sc,
                        float3 n, float3 viewVector, float s,
                        thread float3& diff, thread float3& spec) {
    s *= 0.75;
    float3 r         = reflect(viewVector, n);
    float3 sampleDir = n * (1.0 - s) + r * s;
    diff = SkyColorConv(sky, info, sc, sampleDir, 1.0 - s);
    spec = diff;
    diff *= 1.0 - s;
    spec *= s;
}

// ----------------------------------------------------------------------------
//  SceneLighting — the forward/deferred hybrid composite used by almost every
//  lit material on the "high" quality path.
//    lightScalar (s13): x = sun shadow, y = ambient occlusion (screen space,
//                       produced by globalShadowShader + AO volume passes)
//    deferredLight    : accumulated point/spot/line lights (rgb) + spec (a)
// ----------------------------------------------------------------------------
struct LightingInputs {
    texture2d<float> lightScalar;     // s13
    texture2d<float> deferredLight;   // light accumulation buffer
    sampler          pointClamp;
};

inline void SceneLighting(SkyResources sky, LightingInputs li,
                            constant SunSkyInfo& sun, constant SunSkyRadianceScales& sc,
                            float2 screenUV, float3 n, float3 viewVector,
                            float gloss, float reflectance, float specE, float specStrength,
                            thread float3& shDiff, thread float3& shSpec,
                            thread float3& specHighlight, thread float& shadow) {
    float4 ls          = li.lightScalar.sample(li.pointClamp, screenUV);
    float directShadow = ls.x;
    float ambientOcc   = ls.y;
    shadow = directShadow;

    EnvLighting(sky, sun, sc, n, viewVector, gloss, shDiff, shSpec);
    shDiff *= ambientOcc;
    shSpec *= ambientOcc;

    float sunMod = saturate(dot(sun.mSunDir.xyz, n));
    float spec   = CalcBlinnPhongSchlick(sun.mSunDir.xyz, viewVector, n, specE, reflectance);
    specHighlight = spec * specStrength * sunMod * sun.mSunColor.rgb * directShadow;
    sunMod  = pow(max(sunMod, 0.0001), 1.0 + gloss);       // glossier = tighter wrap
    shDiff += sunMod * sun.mSunColor.rgb * directShadow;

    float4 dl = li.deferredLight.sample(li.pointClamp, screenUV);
    shDiff += dl.rgb;
    shSpec += dl.a;
}

// Approximate occlusion of a pre-integrated sphere lookup by a ground plane
inline float3 ClipToHemisphere(float3 n, float3 ng) {
    float c = dot(n, ng);
    return (n + ng) * sqrt(1.0 + c) / sqrt(8.0);
}

// ----------------------------------------------------------------------------
//  Order-2 (9 coefficient) and order-3 (16) spherical harmonics as used by the
//  per-vertex lighting path (low quality / effects / trees in the near field).
//  Coeff layout: [0]=L00, [1..3]= y z x, [4..8] = xy yz (3z^2-1) zx (x^2-y^2),
//  [9..15] = cubic band used only for the glossy reflection lookup.
// ----------------------------------------------------------------------------
constant float kSH_A1 = 2.0 / 3.0;   // cosine-lobe convolution, band 1
constant float kSH_A2 = 1.0 / 4.0;   // band 2

inline float3 SHEvalBands012(constant float4* sh, float3 x0, bool convolve) {
    float3 x1 = x0 * x0;
    float3 x2 = x0 * x0.yzx;
    float3 b1 = sh[1].xyz * x0.y + sh[2].xyz * x0.z + sh[3].xyz * x0.x;
    float3 b2 = sh[4].xyz * x2.x + sh[5].xyz * x2.y + sh[6].xyz * (3.0 * x1.z - 1.0)
              + sh[7].xyz * x2.z + sh[8].xyz * (x1.x - x1.y);
    if (convolve) { b1 *= kSH_A1; b2 *= kSH_A2; }
    return b1 + b2;
}
inline float3 SHEvalBand3(constant float4* sh, float3 x0) {
    float3 x1 = x0 * x0;
    float3 r = 0;
    r += sh[ 9].xyz * (3.0 * x1.x - x1.y) * x0.y;
    r += sh[10].xyz * x1.x * x0.z;
    r += sh[11].xyz * (5.0 * x1.z - 1.0) * x0.y;
    r += sh[12].xyz * (5.0 * x1.z - 3.0) * x0.z;
    r += sh[13].xyz * (5.0 * x1.z - 1.0) * x0.x;
    r += sh[14].xyz * (x1.x - x1.y) * x0.z;
    r += sh[15].xyz * (x1.x - 3.0 * x1.y) * x0.x;
    return r;
}
// SHDiffSpec9: diffuse irradiance along n, unconvolved radiance along reflect(v,n)
inline void SHDiffSpec9(constant float4* sh, float3 n, float3 viewVector, bool translucency,
                        thread float3& diff, thread float3& spec) {
    diff = sh[0].xyz + SHEvalBands012(sh, n, true);
    float3 r = translucency ? -n : reflect(viewVector, n);
    spec = sh[0].xyz + SHEvalBands012(sh, r, false);
}

// ----------------------------------------------------------------------------
//  Directional ambient occlusion — "directed solid angle" algebra.
//  An occluder is stored as (dir.xyz, w) with w = solid angle / 4pi
//  (0.5 = hemisphere).  From writeDirAO / applyTerrainAOToWorld.
// ----------------------------------------------------------------------------
inline float4 CombineFast(float4 a, float4 b) {
    return float4(a.xyz * a.w + b.xyz * b.w, a.w + b.w - a.w * b.w);
}
inline float4 CombineOverlap(float4 a, float4 b) {
    float w0 = a.w, w1 = b.w;
    float c0 = 1.0 - 2.0 * w0, c1 = 1.0 - 2.0 * w1;
    float s0 = sqrt(1.0 - c0 * c0), s1 = sqrt(1.0 - c1 * c1);
    float ct = c0 * c1, st = s0 * s1;
    float c  = dot(a.xyz, b.xyz);
    float t  = saturate((c - ct + st) / (2.0 * st));
    if (w0 > w1) w1 *= (1.0 - t); else w0 *= (1.0 - t);
    return float4(normalize(a.xyz * w0 + b.xyz * w1), w0 + w1);
}
inline float HemiSolidAngle(float c, float w) {
    float c0 = 1.0 - 2.0 * w;
    float s0 = sqrt(1.0 - c0 * c0);
    float s  = saturate((c + s0) / (2.0 * s0));
    float minW = max(w - 0.5, 0.0), maxW = min(w, 0.5);
    return minW + s * (maxW - minW);
}
// cosine-weighted projection of a spherical cap (area-to-point form factor)
inline float ProjSolidAngle(float c, float w) {
    float c0 = 1.0 - 2.0 * w;
    float s0 = sqrt(max(1e-6, 1.0 - c0 * c0));
    float t  = saturate((c + s0) / (2.0 * s0));
    float ac0 = saturate(c0), iac0 = saturate(-c0);
    float maxF = 1.0 - ac0 * ac0;
    float minF = iac0 * iac0;
    return minF + t * (maxF - minF);
}
inline float3 BendNormal(float c, float w, float3 od, float3 n) {
    float pa = ProjSolidAngle(c, w);
    return normalize(n - od * pa) * pa;
}

// ----------------------------------------------------------------------------
//  Per-instance hue/saturation/value tweak in YIQ space (trees, props, sims)
// ----------------------------------------------------------------------------
inline float3 CalculateHSVTweakedColor(float3 hsvMod, float3 c) {
    const float3 kMin   = float3(-M_PI_F, 0.0, 0.0);
    const float3 kMax   = float3( M_PI_F, 5.0, 2.0);
    // rows of the HLSL matrices -> Metal: build with columns = HLSL rows, then transpose
    const float3x3 yiq = transpose(float3x3(float3(0.299,  0.587,  0.114),
                                            float3(0.596, -0.274, -0.321),
                                            float3(0.211, -0.523,  0.311)));
    const float3x3 rgb = transpose(float3x3(float3(1.0,  0.956,  0.621),
                                            float3(1.0, -0.272, -0.647),
                                            float3(1.0, -1.107,  1.705)));
    float3 p   = hsvMod * (kMax - kMin) + kMin;
    float  hS  = sin(p.r), hC = cos(p.r);
    float3 y   = yiq * c;
    y         *= p.b;                         // value
    y.yz      *= p.g;                         // saturation
    y.yz       = float2(hC * y.y - hS * y.z,  // hue rotation of the IQ chroma plane
                        hS * y.y + hC * y.z);
    return rgb * y;
}
