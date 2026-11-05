// Material shader: vsAOVolume
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;
uniform float4 worldCameraPosition;
uniform float4x4 clipToWorld;
uniform struct { float4 origin; float4 invWidth; float4 tuning; } volumeInfo;
uniform float4x4 clipToModel;
uniform float4 modelCameraPosition;

void main_vertex()
{
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: depthInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float hw = Current.position.w;
    // --- fragment: positionInfoFromDepth   (cond 0000000000000000000000000000000000000000000000ff)
    {
    // Find viewer-relative point on far clip plane for this vertex
    float4 farPoint = mul(Current.position.xyww, clipToWorld);
    farPoint /= farPoint.w;
    farPoint.xyz -= worldCameraPosition.xyz;
    farPoint *= hw; // adjust so we don't interpolate with perspective correction. It's important that farPoint.w == hw.
    Current.texcoord<t0> = farPoint.xyz;
    }
    // --- fragment: volumeInfoFromDepth   (cond 0000000000000000000000000000000000000000000000ff)
    // Volume-relative version of the same. We need to pass up the camera volume position too.
    float3 volMin      = volumeInfo.origin.xyz;
    float3 volInvScale = volumeInfo.invWidth.xyz;
    float4 farVolPoint = mul(clipPosition.xyww, clipToModel);
    farVolPoint /= farVolPoint.w;
    farVolPoint.xyz -= modelCameraPosition.xyz;
    farVolPoint.xyz *= volInvScale;
    float3 volumeCameraPosition = (modelCameraPosition.xyz - volMin) * volInvScale;
    Current.texcoord<t0> = farVolPoint * hw;
    Current.texcoord<t1>.xyz = volumeCameraPosition;
    Current.texcoord<t1>.w = 1;
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 renderTargetInfo0;
extern uniform sampler normalMap : register(s14);
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
uniform float4 worldCameraPosition;
uniform float4 nearFar;
uniform float4 worldCameraPosition;
uniform struct { float4 origin; float4 invWidth; float4 tuning; } volumeInfo;
uniform float4x3 worldToModel;
extern uniform sampler3D volumeTexture : register(s0);
float4 CombineFast(float4 dw0, float4 dw1)
// Combine two directed solid angles probabilistically
// dw.xyz is direction, dw.w is scaled solid angle, 0.5 = hemisphere, 1 = entire sphere
{
float4 result;
result.w   = dw0.w + dw1.w - dw0.w * dw1.w;
result.xyz = dw0.xyz * dw0.w + dw1.xyz * dw1.w;
return result;
}
float4 CombineOverlap(float4 dw0, float4 dw1)
// Combine two directed solid angles taking overlap into account,
// but as cheaply as possible. (The full formula is expensive.)
// We lerp linearly between the maximum possible solid angle (no
// overlap, w0 + w1), and the minimum (max(w0, w1), complete overlap),
// depending on an overlap term. This is surprisingly close to the
// correct result.
{
float w0 = dw0.w;
float w1 = dw1.w;
float c0 = 1 - 2 * w0;  // cos factors
float c1 = 1 - 2 * w1;
float s0 = sqrt(1 - c0 * c0);
float s1 = sqrt(1 - c1 * c1);
float ct = c0 * c1;
float st = s0 * s1;
float c = dot(dw0.xyz, dw1.xyz);
// this gives us a value between 0 (no overlap)
// and 1 (full overlap)
// half overlap is about c = max(c0, c1)
// float t = step(c, ct - st, ct + st);
float t = saturate((c - ct + st) / (2 * st));
// TODO: optimise, if the compiler's not doing it, by forming a 01 mask.
if (w0 > w1)
w1 *= (1 - t);
else
w0 *= (1 - t);
float4 result;
result.w = w0 + w1;
result.xyz = normalize(dw0.xyz * w0 + dw1.xyz * w1);
return result;
}
float HemiSolidAngle(float c, float w)
// Returns the solid angle clipped to a hemisphere defined by a normal.
// c is cosine between occlusion direction and normal
// w is the solid angle of occlusion.
{
float c0 = 1 - 2 * w;
float s0 = sqrt(1 - c0 * c0);
float s = saturate((c + s0) / (2 * s0));
float minW = max(w - 0.5, 0.0); // usually 0 unless w is bigger than a hemisphere
float maxW = min(w, 0.5);
float wn = minW + s * (maxW - minW);   // solid angle in the hemisphere above n obscured by dirW
return wn;
}
float ProjSolidAngle(float c, float w)
// Calculates an approximation to the projection of a spherical cap
// of the given solid angle onto the view circle, i.e., its cos-weighted
// projection for a given normal. (AKA the area-to-point form factor.)
// c is cosine between occlusion direction and normal
// w is the solid angle of occlusion.
{
float c0 = 1 - 2 * w;
float s0 = sqrt(1 - c0 * c0);
float t = saturate((c + s0) / (2 * s0));
float ac0  = saturate(c0);
float iac0 = saturate(-c0);
float maxF = 1 - ac0 * ac0;
float minF = iac0 * iac0;
float fn;
fn = minF + t * (maxF - minF);    // Cheapest version, over-dark at perpendicular angles.
return fn;
}
float3 BendNormal(float c, float w, float3 od, float3 n)
// Calculates bent normal.
{
float pa = ProjSolidAngle(c, w);
n = normalize(n - od * pa); // bend normal accordingly
n *= pa;
return n;
}

void main_pixel()
{
    // --- fragment: depthNormalInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    float3 worldNormalPack = tex2D(normalMap, screenUV).xyz;
    float3 worldNormal = normalize(2 * worldNormalPack - 1);
    // --- fragment: positionInfoFromDepth   (cond 0000000000000000000000000000000000000000000000ff)
    float3 farPoint  = In.texcoord<t0>.xyz / In.texcoord<t0>.z;
    float3 viewPosition  = worldCameraPosition.xyz;
    float3 viewDirection = normalize(farPoint);
    float3 worldDistance = make_float3(depth * nearFar.y);
    float3 worldPosition = viewPosition + farPoint * depth;
    // --- fragment: volumeInfoFromDepth   (cond 0000000000000000000000000000000000000000000000ff)
    float3 farVolPoint = In.texcoord<t0>.xyz / In.texcoord<t0>.w;  // undo perspective correction
    float3 volumeCameraPosition = In.texcoord<t1>.xyz;
    float3 volumeUVW = volumeCameraPosition + farVolPoint * depth;
    // --- fragment: writeDirAO   (cond 0000000000000000000000000000000000000000000000ff)
    clip(-abs(saturate(volumeUVW) - volumeUVW));
    float3 modelNormal = normalize(mul(worldNormal, make_float3x3(worldToModel)));
    volumeUVW += modelNormal * volumeInfo.invWidth.xyz * volumeInfo.tuning.z;
    float4 dirW = tex3D(volumeTexture, volumeUVW);
    float3 dir = 2 * dirW.xyz - 1;
    float cw = dot(-dir, modelNormal);
    dir = normalize(dir);
    float c = dot(-dir, modelNormal);
    float w = dirW.w;
    float pw = ProjSolidAngle(c, w);
    float ks = volumeInfo.tuning.x;
    float kc = volumeInfo.tuning.y;
    pw = 1 - pow(1 - pw * ks, kc);    
    Current.color.rgb = float3(0, 0, 0);
    Current.color.w = pw;
}
