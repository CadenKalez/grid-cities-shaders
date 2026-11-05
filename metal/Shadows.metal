// =============================================================================
//  Shadows.metal — sun shadow maps, PCF filter family, screen-space shadow
//  resolve into the "light scalar" buffer, cloud shadows, spot-light shadows.
//
//  Pipeline (from the render-pass table):
//    shadows pass:  renderShadowMap / renderShadowMapAlphaMask / tree caster
//                   -> shadowMapDepthRT (+ shadowMapColorRT)
//    globalShadowShader (full-screen quad, reads G-buffer depth):
//                   world position from depth -> ShadowEvalOrtho(style 7)
//                   -> lightScalar.x   (consumed by SceneLighting)
//    cloudShadowShader: multiplies 3 scrolling cloud layers into the same buffer
//    spotShadowPF:  deferred spot lights multiply their contribution by shadow
//
//  Reference fragments: vs/0051, ps/0028-0029, ps/0395-0410, ps/0423, ps/0434
// =============================================================================
#include "Common.h"

// ------------------------------------------------------------- caster pass --
struct ShadowCasterFrame {
    float4x4 modelToClip;
    float3x4 modelToCamera;
    float4   rangeAndStrength;    // x = near, y = 1/(far-near)  -> linear light depth
};
struct ShadowCasterOut { float4 position [[position]]; float4 t0; };

vertex ShadowCasterOut renderShadowMapVS(const device float4* pos [[buffer(0)]],
                                         const device float2* uv  [[buffer(2)]],
                                         constant ShadowCasterFrame& f [[buffer(1)]],
                                         uint vid [[vertex_id]]) {
    ShadowCasterOut o;
    float4 p = pos[vid];
    // linear depth in light space, written to colour (D3D9 had no depth textures
    // on all hardware, so depth is stored in an R channel)
    float linZ = (xform(p, f.modelToCamera).z - f.rangeAndStrength.x) * f.rangeAndStrength.y;
    o.position = xform(p, f.modelToClip);
    o.t0 = float4(linZ, uv[vid], linZ);
    return o;
}
fragment float4 renderShadowMapPS(ShadowCasterOut in [[stage_in]]) {
    return EncodeShadowDepth(saturate(in.t0.x));
}
fragment float4 renderShadowMapAlphaMaskPS(ShadowCasterOut in [[stage_in]],
                                           texture2d<float> diffuse [[texture(0)]]) {
    constexpr sampler s(filter::linear, address::repeat);
    if (diffuse.sample(s, in.t0.yz).a < 0.5) discard_fragment();   // foliage / fences
    return EncodeShadowDepth(saturate(in.t0.w));
}

// --------------------------------------------------------------- receivers --
struct ShadowParams {
    float4x4 worldToLight;        // world -> shadow texture space (xy uv, z depth)
    float4   rttInfoShadow;       // xy = map size, zw = 1/size
};

// The original exposes 8 styles selected per fragment at build time:
//   2 single tap, 3 manual 2x2 bilinear PCF, 4 Fetch4 bilinear PCF (ATI),
//   5 four Fetch4 = 4x4 weighted PCF, 6 hardware PCF, 7 four HW PCF taps at
//   +-0.5 texel (the shipping choice), 8 receiver-plane depth bias (disabled,
//   "doesn't work").  Metal: depth2d + sample_compare gives HW PCF directly;
//   the Fetch4 variants map onto gather().
constant float2 kOff = float2(0.5, 0.25);       // offset (texels), weight

inline float ShadowOrtho(depth2d<float> map, texture2d<float> mapColor, float4 sp,
                         constant ShadowParams& P, int style) {
    constexpr sampler cmp(filter::linear, compare_func::less_equal, address::clamp_to_edge);
    constexpr sampler pt (filter::nearest, address::clamp_to_edge);
    float shadow = 1.0;
    if (style == 2) {
        shadow = float(sp.z <= mapColor.sample(pt, sp.xy).x);
    } else if (style == 3 || style == 4) {
        float4 d;
        if (style == 3) {
            float3 o = float3(P.rttInfoShadow.zw, 0);
            d = float4(mapColor.sample(pt, sp.xy).x,          mapColor.sample(pt, sp.xy + o.zy).x,
                       mapColor.sample(pt, sp.xy + o.xy).x,   mapColor.sample(pt, sp.xy + o.xz).x);
        } else {
            d = mapColor.gather(pt, sp.xy).wzxy;              // Fetch4 swizzle .agbr
        }
        d = greater_equal(d, sp.z);
        float2 bw = fract(sp.xy * P.rttInfoShadow.xy);
        float2 lr = mix(d.xy, d.wz, bw.x);
        shadow = mix(lr.x, lr.y, bw.y);
    } else if (style == 6) {
        shadow = map.sample_compare(cmp, sp.xy, sp.z);
    } else { // style 7 (default high quality): 4 HW-PCF taps in an X pattern
        float4 o = kOff.x * float4(1, 1, 0, -1) * P.rttInfoShadow.zwzw;
        float4 d = float4(map.sample_compare(cmp, sp.xy + o.xy, sp.z),
                          map.sample_compare(cmp, sp.xy + o.xw, sp.z),
                          map.sample_compare(cmp, sp.xy - o.xw, sp.z),
                          map.sample_compare(cmp, sp.xy - o.xy, sp.z));
        shadow = saturate(dot(d, float4(kOff.y)));
    }
    // "plump, smooth, and darken shadow (important!)" — squaring tightens the
    // penumbra of the small kernel and darkens the core.
    return shadow * shadow;
}

// projective (spot light) variant: divide-through then same filters
inline float ShadowProj(depth2d<float> map, texture2d<float> mapColor, float4 sp,
                        constant ShadowParams& P, int style) {
    sp.xyz /= sp.w;
    return ShadowOrtho(map, mapColor, float4(sp.xyz, 1), P, style);
}

// Full-screen deferred shadow resolve: reconstruct world position from the
// packed G-buffer depth and the interpolated far-plane ray.
struct FSQuadOut { float4 position [[position]]; float3 farPoint; };
struct DepthFrame {
    float4x4 clipToWorld;
    float4   worldCameraPosition;
    float4   renderTargetInfo0;   // zw = 1/size
};

vertex FSQuadOut positionInfoFromDepthQuadVS(uint vid [[vertex_id]],
                                             constant DepthFrame& f [[buffer(1)]]) {
    float2 c = float2((vid << 1) & 2, vid & 2) * 2.0 - 1.0;   // full-screen triangle
    FSQuadOut o;
    o.position = float4(c, 0, 1);
    float4 far = float4(c, 1, 1) * f.clipToWorld;
    o.farPoint = far.xyz / far.w - f.worldCameraPosition.xyz;  // camera -> far plane
    return o;
}
inline float3 WorldPosFromDepth(float4 fragPos, float3 farPoint, constant DepthFrame& f,
                                texture2d<float> depthMap, thread float& depth) {
    constexpr sampler pt(filter::nearest, address::clamp_to_edge);
    float2 uv = (fragPos.xy) * f.renderTargetInfo0.zw;
    depth = UnpackDepth(depthMap.sample(pt, uv));      // 0..1 of the far distance
    return f.worldCameraPosition.xyz + farPoint * depth;
}

fragment float4 globalShadowPS(FSQuadOut in [[stage_in]],
                               constant DepthFrame& f   [[buffer(1)]],
                               constant ShadowParams& P [[buffer(2)]],
                               texture2d<float> depthMap    [[texture(15)]],
                               depth2d<float>   lightDepth  [[texture(13)]],
                               texture2d<float> lightColor  [[texture(12)]]) {
    float depth;
    float3 wp = WorldPosFromDepth(in.position, in.farPoint, f, depthMap, depth);
    float4 sp = float4(wp, 1) * P.worldToLight;
    float s = ShadowOrtho(lightDepth, lightColor, sp, P, 7);
    return float4(s);                                   // -> lightScalar
}

// Cloud shadows: three tiled cloud textures at different altitudes, projected
// along the sun direction and scrolled with game time.
struct CloudParams { float4 shadowFrustumInfo; float4 gameInfo; };
fragment float4 cloudShadowPS(FSQuadOut in [[stage_in]],
                              constant DepthFrame& f   [[buffer(1)]],
                              constant CloudParams& C  [[buffer(2)]],
                              texture2d<float> depthMap [[texture(15)]],
                              texture2d<float> cloud0   [[texture(1)]],
                              texture2d<float> cloud1   [[texture(2)]],
                              texture2d<float> cloud2   [[texture(3)]]) {
    constexpr sampler s(filter::linear, address::repeat);
    float depth;
    float3 wp = WorldPosFromDepth(in.position, in.farPoint, f, depthMap, depth);
    const float  h[3]   = { 200.0, 230.0, 350.0 };
    const float2 vel[3] = { float2(-13, -60), float2(14, -49.5), float2(28, -88) };
    const float2 sz[3]  = { float2(5900), float2(6148), float2(11096) };
    float2 p[3];
    for (int i = 0; i < 3; ++i)
        p[i] = (wp.xy + (h[i] - wp.z) * C.shadowFrustumInfo.xy * -1.0 + vel[i] * C.gameInfo.x) / sz[i];
    float sh = 0.45 + 0.55 * clamp(cloud1.sample(s, p[1]).g + cloud2.sample(s, p[2]).b
                                   - 0.5 * cloud0.sample(s, p[0]).r, 0.0, 1.0);
    return float4(sh, sh, sh, 1);     // blended multiplicatively over lightScalar
}
