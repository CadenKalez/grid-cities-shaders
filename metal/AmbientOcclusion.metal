// =============================================================================
//  AmbientOcclusion.metal — volumetric directional AO, bounce light and
//  terrain-onto-world AO.
//
//  The engine does NOT use SSAO.  Each building/prop carries a small 3-D
//  "AO volume" texture baked offline: every voxel stores the dominant
//  occlusion direction (rgb) and occluded solid angle (a).  At runtime the
//  volume's bounding box is rasterised (vsAOVolume / vsAOVolumeInstanced /
//  vsAOVolumeAndBounce), each covered pixel reconstructs its world position
//  from the G-buffer, transforms into volume UVW and evaluates the cosine-
//  weighted occlusion with ProjSolidAngle().  Result is MIN/multiply-blended
//  into lightScalar.y, which SceneLighting() uses to scale sky ambient.
//
//  Reference fragments: ps/0130 writeDirAO, ps/0131 writeBounceLight,
//  ps/0132 writeDirAOInstanced, ps/0134 applyTerrainAOToWorld,
//  vs volumeInfoFromDepth / positionInfoFromDepth.
// =============================================================================
#include "Common.h"

struct VolumeInfo {
    float4 origin;       // volume min corner (model space)
    float4 invWidth;     // 1 / extent
    float4 tuning;       // x: strength ks, y: contrast kc, z: normal push (voxels)
};
struct AOFrame {
    float4x4 modelToClip;
    float4x4 clipToModel;
    float3x4 worldToModel;
    float4   modelCameraPosition;
    float4   renderTargetInfo0;    // zw = 1/size
    float4   tintParams;           // bounce light colour
};

struct AOVolumeOut {
    float4 position [[position]];
    float4 farVolPoint;            // camera->far-plane ray in volume UVW, * w
    float3 volumeCameraPos;        // camera position in volume UVW
};

// Rasterise the volume's box; pass a per-vertex ray so the pixel shader can
// rebuild volume UVW = camUVW + ray * depth without a matrix multiply.
vertex AOVolumeOut aoVolumeVS(const device float4* boxVerts [[buffer(0)]],
                              constant VolumeInfo& V [[buffer(1)]],
                              constant AOFrame& f    [[buffer(2)]],
                              uint vid [[vertex_id]]) {
    float3 p = V.origin.xyz + boxVerts[vid].xyz / V.invWidth.xyz;   // unit box -> model
    float4 clip = float4(p, 1) * f.modelToClip;
    float hw = clip.w;
    float4 far = clip.xyww * f.clipToModel;
    far /= far.w;
    far.xyz = (far.xyz - f.modelCameraPosition.xyz) * V.invWidth.xyz;
    AOVolumeOut o;
    o.position        = clip;
    o.farVolPoint     = far * hw;      // undo perspective-correct interpolation later
    o.volumeCameraPos = (f.modelCameraPosition.xyz - V.origin.xyz) * V.invWidth.xyz;
    return o;
}

struct AOOut {
    float4 ao     [[color(0)]];   // .a -> lightScalar ambient term (blend: dst *= 1-src)
    float4 bounce [[color(1)]];   // coloured bounce added to the light buffer
};

fragment AOOut aoVolumePS(AOVolumeOut in [[stage_in]],
                          constant VolumeInfo& V [[buffer(1)]],
                          constant AOFrame& f    [[buffer(2)]],
                          texture3d<float> volumeTexture [[texture(0)]],
                          texture2d<float> normalMap     [[texture(14)]],
                          texture2d<float> depthMap      [[texture(15)]]) {
    constexpr sampler pt (filter::nearest, address::clamp_to_edge);
    constexpr sampler lin(filter::linear,  address::clamp_to_edge);
    float2 uv    = in.position.xy * f.renderTargetInfo0.zw;
    float  depth = UnpackDepth(depthMap.sample(pt, uv));
    float3 worldNormal = normalize(2.0 * normalMap.sample(pt, uv).xyz - 1.0);

    float3 farVol    = in.farVolPoint.xyz / in.farVolPoint.w;
    float3 volumeUVW = in.volumeCameraPos + farVol * depth;
    if (any(volumeUVW != saturate(volumeUVW))) discard_fragment();   // outside the box

    float3 modelNormal = normalize(xformDir(worldNormal, f.worldToModel));
    volumeUVW += modelNormal * V.invWidth.xyz * V.tuning.z;            // avoid self-occlusion

    float4 dirW = volumeTexture.sample(lin, volumeUVW);
    float3 dir  = normalize(2.0 * dirW.xyz - 1.0);
    float  c    = dot(-dir, modelNormal);
    float  pw   = ProjSolidAngle(c, dirW.w);
    pw = 1.0 - pow(1.0 - pw * V.tuning.x, V.tuning.y);                 // artist contrast curve

    AOOut o;
    o.ao     = float4(0, 0, 0, pw);
    // writeBounceLight: occluded light is partially re-emitted with the
    // occluder's tint — a one-bounce GI approximation per volume.
    o.bounce = float4(pw * 0.7 * f.tintParams.rgb, 0);
    return o;
}

// -----------------------------------------------------------------------------
//  Terrain occluding the world (applyTerrainAOToWorldQuadShader):
//  "fake AO cast by the terrain onto the world by computing each screen pixel's
//  world height and adding AO based on how far the pixel is above the terrain"
// -----------------------------------------------------------------------------
struct TerrainAOFrame {
    float3x4 cameraToWorld;
    float4   nearFar;
    float4   renderTargetInfo0;
};
struct TerrainAOIn { float4 position [[position]]; float4 toFarClip; };

fragment float4 applyTerrainAOToWorldPS(TerrainAOIn in [[stage_in]],
                                        constant TerrainAOFrame& f [[buffer(1)]],
                                        texture2d<float> depthMap      [[texture(15)]],
                                        texture2d<float> normalMap     [[texture(14)]],
                                        texture2d<float> controlMapTex [[texture(0)]],
                                        texture2d<float> heightMap     [[texture(1)]]) {
    constexpr sampler pt (filter::nearest, address::clamp_to_edge);
    constexpr sampler lin(filter::linear,  address::clamp_to_edge);
    float2 uv    = in.position.xy * f.renderTargetInfo0.zw;
    float  depth = UnpackDepth(depthMap.sample(pt, uv));
    float3 n     = normalize(2.0 * normalMap.sample(pt, uv).xyz - 1.0);
    float3 viewPos  = in.toFarClip.xyz * depth;
    float3 worldPos = xform(float4(viewPos, 1), f.cameraToWorld);
    if (any(abs(worldPos.xy) > 1024.0)) discard_fragment();            // 2 km city tile

    float2 topDownUV = worldPos.xy / 2048.0 + 0.5;
    float4 control   = controlMapTex.sample(lin, topDownUV);
    float  height    = heightMap.sample(lin, topDownUV).r * 2048.0 - 1024.0;

    float occ = 1.0 - saturate((worldPos.z - height) / 6.0);           // fades out over 6 m
    occ = occ * occ * 0.5;                                              // <= hemisphere
    float c  = dot(-float3(0, 0, 1), n);                                // occluder is "down"
    float pw = ProjSolidAngle(c, occ);
    pw = 1.0 - pow(1.0 - pw, 3.0);
    return float4(0, 0, 0, pw * control.w);
}
