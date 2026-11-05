// =============================================================================
//  Atmospherics.metal — height fog / aerial perspective (material
//  "atmospherics": depthInfo + positionInfoFromDepthQuad + atmospherics).
//
//  Full-screen pass over the G-buffer.  In-scatter colour is the Perez sky
//  along the view ray (with the horizon lifted near the sun), extinction is an
//  exponential-height-fog optical depth integrated analytically along the ray.
//  Two layers: one for geometry, a second for the sky dome (depth > 0.99).
//  The result is blended as  dst = dst * a + rgb  (premultiplied).
// =============================================================================
#include "Common.h"

constant float kGroundScale     = 1024.0;
constant float kGroundZero      = -870.0;      // atmosphere base height (m)
constant float kScatterStrength = 1.5;
constant bool  kUseQuadraticDensity = true;

// optical depth of exp(-alpha*(h-hs)) fog between viewer and point
inline float AtmosphericDensity(float3 worldPos, float3 viewPos, float3 viewDir,
                                float hs, float alpha, float B0) {
    float h0 = worldPos.z - hs;
    float K  = B0 / (alpha * viewDir.z);
    return K * (exp(-alpha * h0) - exp(-alpha * (viewPos.z - hs)));
}

inline float3 ScatterColor(SkyResources sky, constant SunSkyInfo& info,
                           constant SunSkyRadianceScales& sc, float3 v) {
    float cosGamma = dot(info.mSunDir.xyz, v);
    float co       = saturate(1.0 - cosGamma) * 0.2;          // keep horizon from going black
    float cosTheta = mix(co, 1.0, abs(v.z));
    return SkyColorTableCompressed(sky.skyTable, sky.smp, info, sc, cosTheta + 0.01, cosGamma, 0.0, true);
}

struct AtmIn { float4 position [[position]]; float3 farPoint; };
struct AtmFrame { float4 worldCameraPosition; float4 renderTargetInfo0; };

fragment float4 atmosphericsPS(AtmIn in [[stage_in]],
                               constant AtmFrame& f              [[buffer(1)]],
                               constant SunSkyInfo& sun          [[buffer(2)]],
                               constant SunSkyRadianceScales& sc [[buffer(3)]],
                               texture2d<float> depthMap [[texture(15)]],
                               texture2d<float> skyTable [[texture(11)]]) {
    constexpr sampler pt (filter::nearest, address::clamp_to_edge);
    constexpr sampler lin(filter::linear,  address::clamp_to_edge);
    float2 uv     = in.position.xy * f.renderTargetInfo0.zw;
    float  depth  = UnpackDepth(depthMap.sample(pt, uv));
    float3 viewP  = f.worldCameraPosition.xyz;
    float3 viewD  = normalize(in.farPoint);
    float3 worldP = viewP + in.farPoint * depth;

    float3 rgb = ScatterColor(SkyResources{skyTable, lin}, sun, sc, viewD);
    float4 w = sun.mDynamicWeather;             // density, falloff for 2 layers (weather system)
    float d1 = AtmosphericDensity(worldP, viewP, viewD, kGroundZero, w.y / kGroundScale, w.x / kGroundScale);
    float d2 = AtmosphericDensity(worldP, viewP, viewD, kGroundZero, w.w / kGroundScale, w.z / kGroundScale);
    float density = (depth > 0.99) ? d2 : d1;
    float tau = kUseQuadraticDensity ? exp(-(density * density)) : exp(-density);  // softer near field
    return float4(rgb * (1.0 - tau) * kScatterStrength, tau);
}
