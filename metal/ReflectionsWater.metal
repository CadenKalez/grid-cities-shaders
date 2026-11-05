// =============================================================================
//  ReflectionsWater.metal — reflections and HD water.
//
//  Reflections in the engine are all approximations:
//    * sky reflections: the Perez sky LUT sampled along R (EnvLighting, water)
//    * vehicles: a static cube map (s6) lerped in at 15 % * specStrength
//    * water: sky-only reflection + screen-space refraction of the HDR colour
//      buffer (no planar reflection pass), Fresnel, depth-based absorption,
//      shoreline foam from a ring-sampled terrain height.
//  Water surface: FFT ocean (initFFT/FFTX/FFTY -> WaterHeight/Choppy/Normals)
//  displaces a CDLOD-style terrain grid in the vertex shader.
//
//  Reference: ps/0250 vehicleCubeSamplersPS, ps/0264 vehicleReflectionPS,
//  vs/0169 hdWaterVS, ps/0206 hdWaterNormalPS, ps/0207 hdWaterPS.
//  The FOAM_* / WATER_* macros are injected by the engine at compile time and
//  were not present in the data; the values below are tunable placeholders.
// =============================================================================
#include "Common.h"

// ---- tunables (not recovered; chosen to give plausible results) ----------
constant int   FOAM_HEIGHT_TAP_COUNT        = 8;
constant float FOAM_HEIGHT_TAP_SPACING      = 1.0;
constant float FOAM_MAX_DEPTH               = 4.0;
constant float FOAM_SATURATION              = 4.0;
constant float FOAM_TILING                  = 64.0;
constant float FOAM_DIFFUSE_EFFECT          = 0.8;
constant float WATER_HEIGHT_MAP_SCALE       = 4.0;
constant float WATER_HEIGHT_MAP_BIAS        = -2.0;
constant float WATER_HEIGHT_MAP_TILING      = 32.0;
constant float WATER_HEIGHT_MAP_TILING_FOAM = 4.0;
constant float WATER_CHOPPY_MAP_TILING      = 32.0;
constant float WATER_CHOPPY_MAP_SCALE       = 2.0;
constant float WATER_COARSE_NORMAL_SPACING  = 1.0 / 2048.0;
constant float WATER_COARSE_HEIGHT_SCALE    = 0.02;
constant float WATER_NORMAL_MAP_TILING1     = 96.0;
constant float WATER_NORMAL_MAP_TILING2     = 211.0;
constant float WATER_NORMAL_MAP_BLEND1      = 0.6;
constant float WATER_NORMAL_MAP_BLEND2      = 0.4;

// ------------------------------------------------------------- vehicles ----
inline float3 VehicleReflection(float3 finalColor, texturecube<float> refl, sampler s,
                                float3 reflectedView, float specStrength) {
    const float reflectionIntensity = 0.15;
    return mix(finalColor, refl.sample(s, reflectedView).rgb, specStrength * reflectionIntensity);
}

// ----------------------------------------------------------------- water ----
struct TerrainRegionInfoVS {
    float4   mMisc;          // x = water level, y = grid uv scale
    float4   mTessellation;  // LOD edge morph flags (N,S,E,W)
    float4   mMorph;
    float4   mMapping;       // terrain height-map uv scale/offset
    float4x4 mMatrix;        // patch -> world (column-vector convention, as in HLSL mul(M,v))
};
struct WaterFrame {
    float4x4 worldToClip;
    float4   worldCameraPosition;
    float4   nearFar;
    float4   screenInfo;
};
struct WaterStrataInfo { float4 mColor; float4 mReflectionParams; float4 mSpecularNormal; float4 mSunDir; };

struct WaterVOut {
    float4 position [[position]];
    float4 t0;      // water uv, terrain uv
    float4 t1;      // x = water level, zw = height tap spacing
    float4 t2;      // world position
};

vertex WaterVOut hdWaterVS(const device float4* grid [[buffer(0)]],
                           constant TerrainRegionInfoVS& R [[buffer(1)]],
                           constant WaterFrame& f [[buffer(2)]],
                           texture2d<float> choppyMap [[texture(0)]],
                           texture2d<float> heightMap [[texture(1)]],
                           uint vid [[vertex_id]]) {
    constexpr sampler s(filter::linear, address::repeat);
    float4 g = grid[vid];
    float uvScale = R.mMisc.y;
    float2 flatPos = g.xy;
    float2 terrainUV = (flatPos / uvScale + 0.5) * R.mMapping.xy + R.mMapping.zw;
    flatPos = (R.mMatrix * float4(flatPos, 0, 1)).xy;
    float2 waterUV = flatPos / 16384.0;
    float3 choppy  = choppyMap.sample(s, waterUV * WATER_CHOPPY_MAP_TILING, level(0)).xyz;
    float  h       = heightMap.sample(s, waterUV * WATER_HEIGHT_MAP_TILING, level(0)).x;
    h = min(h * WATER_HEIGHT_MAP_SCALE + WATER_HEIGHT_MAP_BIAS, 0.0) + R.mMisc.x; // never above sea level
    flatPos += choppy.xy * WATER_CHOPPY_MAP_SCALE;          // horizontal "choppy" displacement
    float3 wp = float3(flatPos, h);
    WaterVOut o;
    o.position = float4(wp, 1) * f.worldToClip;
    o.t0 = float4(waterUV, terrainUV);
    o.t1 = float4(R.mMisc.x, R.mMorph.yzw);
    o.t2 = float4(wp, 1);
    return o;
}

// Normal pass: coarse normal from 3 height taps (large swells) + two tiled
// detail normal maps re-oriented onto it.
fragment float4 hdWaterNormalPS(WaterVOut in [[stage_in]],
                                texture2d<float> heightMap [[texture(0)]],
                                texture2d<float> normalMap [[texture(1)]]) {
    constexpr sampler s(filter::linear, address::repeat);
    float2 uv = in.t0.xy;
    float3 p0 = float3(uv + float2( -3, -13) * WATER_COARSE_NORMAL_SPACING, 0);
    float3 p1 = float3(uv + float2( 13,   4) * WATER_COARSE_NORMAL_SPACING, 0);
    float3 p2 = float3(uv + float2(-11,  10) * WATER_COARSE_NORMAL_SPACING, 0);
    p0.z = heightMap.sample(s, p0.xy).x * WATER_COARSE_HEIGHT_SCALE;
    p1.z = heightMap.sample(s, p1.xy).x * WATER_COARSE_HEIGHT_SCALE;
    p2.z = heightMap.sample(s, p2.xy).x * WATER_COARSE_HEIGHT_SCALE;
    float3 coarse = normalize(cross(p1 - p0, p2 - p0));
    float3 n1 = normalMap.sample(s, uv * WATER_NORMAL_MAP_TILING1).xyz * 2.0 - 1.0;
    float3 n2 = normalMap.sample(s, uv * WATER_NORMAL_MAP_TILING2).xyz * 2.0 - 1.0;
    float3 detail = normalize(n1 * WATER_NORMAL_MAP_BLEND1 + n2 * WATER_NORMAL_MAP_BLEND2);
    float3 tz = coarse, tx = float3(1, 0, 0);
    float3 ty = normalize(cross(tz, tx));
    tx = normalize(cross(ty, tz));
    float3 n = detail.x * tx + detail.y * ty + detail.z * tz;
    return float4(n * 0.5 + 0.5, 1.0);
}

fragment float4 hdWaterPS(WaterVOut in [[stage_in]],
                          constant WaterFrame& f            [[buffer(1)]],
                          constant SunSkyInfo& sun          [[buffer(2)]],
                          constant SunSkyRadianceScales& sc [[buffer(3)]],
                          constant WaterStrataInfo& W       [[buffer(4)]],
                          texture2d<float> terrainHeight [[texture(0)]],
                          texture2d<float> waterHeight   [[texture(1)]],
                          texture2d<float> screenNormal  [[texture(2)]],
                          texture2d<float> foamTex       [[texture(3)]],
                          texture2d<float> hdrColor      [[texture(4)]],
                          texture2d<float> screenDepth   [[texture(5)]],
                          texture2d<float> skyTable      [[texture(11)]]) {
    constexpr sampler s (filter::linear, address::repeat);
    constexpr sampler cl(filter::linear, address::clamp_to_edge);
    float2 screenUV = in.position.xy * f.screenInfo.zw;
    float3 worldPos = in.t2.xyz;

    // shoreline depth: ring of taps on the terrain height map (smooths the coast)
    float spacing = FOAM_HEIGHT_TAP_SPACING * in.t1.w;
    float integral = 0;
    for (int i = 0; i < FOAM_HEIGHT_TAP_COUNT; ++i) {
        float a = 40.0 / 57.3 + (2.0 * M_PI_F / FOAM_HEIGHT_TAP_COUNT) * i;
        integral += terrainHeight.sample(cl, in.t0.zw + float2(sin(a), cos(a)) * spacing).x;
    }
    float tH = integral / FOAM_HEIGHT_TAP_COUNT * 2048.0 - 1024.0;
    float wH = waterHeight.sample(s, in.t0.zw * WATER_HEIGHT_MAP_TILING_FOAM).x;
    wH = min(wH * WATER_HEIGHT_MAP_SCALE + WATER_HEIGHT_MAP_BIAS, 0.0) + in.t1.x;
    float waterDepth = max(0.0, wH - tH - 1.0);

    float3 n = screenNormal.sample(cl, screenUV).xyz * 2.0 - 1.0;
    float3 V = normalize((f.worldCameraPosition.xyz - worldPos) * float3(1, 1, 0.9));
    float3 L = sun.mSunDir.xyz;

    // stylised Fresnel: 0.925 - (5 cos^2)^(1/4)
    float fres = sqrt(sqrt(5.0 * dot(V, n) * dot(V, n)));
    fres = clamp(0.925 - saturate(fres), 0.01, 1.0);

    float3 sky = SkyColor(SkyResources{skyTable, cl}, sun, sc, reflect(-V, n));
    float3 R1  = reflect(L, n);
    float phong = max(0.0, pow(max(dot(R1, V), 0.0), W.mSpecularNormal.x) * W.mSpecularNormal.y);
    float3 shSpec = sun.mSunColor.xyz * phong;
    float3 reflected = sky;
    float3 combined  = mix(float3(0), reflected, fres);
    float  transparency = saturate(0.15 + fres);

    float foam = saturate((FOAM_MAX_DEPTH - waterDepth) / FOAM_SATURATION);
    float4 foamColor = foamTex.sample(s, fract(in.t0.xy * FOAM_TILING));
    foam *= foamColor.a; foam *= foam;
    shSpec *= 1.0 - saturate(foam * 2.5);
    float3 waterColor = combined * sky + shSpec;

    // screen-space refraction: offset by the normal, reject samples in front of the water
    float2 refrUV = screenUV + float2(sin(n.x * M_PI_F), sin(n.y * M_PI_F)) * 0.03;
    float4 hdr    = hdrColor.sample(cl, refrUV);
    float  sceneZ = UnpackDepth(screenDepth.sample(cl, refrUV)) * f.nearFar.y;
    float  waterCamZ = (float4(worldPos, 1) * f.worldToClip).w;
    foam *= 1.0 - smoothstep(2000.0, 10000.0, waterCamZ);
    float waterZ = sceneZ - waterCamZ;
    if (waterZ <= 0.0) {                         // refracted sample is above water: use unrefracted
        hdr    = hdrColor.sample(cl, screenUV);
        sceneZ = UnpackDepth(screenDepth.sample(cl, screenUV)) * f.nearFar.y;
        waterZ = sceneZ - waterCamZ;
    }
    // Beer-ish absorption: blend to a dark basin colour over 70 m of water
    float under = mix(0.30, 0.005, smoothstep(0.0, 70.0, waterZ));
    float3 basin = float3(0.06, 0.15, 0.12) * 0.15;
    float3 c = mix(mix(basin, hdr.rgb, under), waterColor, transparency);
    foamColor.rgb = mix(foamColor.rgb, foamColor.rgb * sky, FOAM_DIFFUSE_EFFECT);
    return float4(mix(c, foamColor.rgb, foam), 1.0);
}
