// Shader fragment  [PS slot 132]  writeDirAOInstanced

// ---- uniform parameters ----
uniform struct { float4 origin; float4 invWidth; float4 tuning; } volumeInfo;   // reg-meta 02c002c00003000000000008
uniform float4x3 worldToModel;   // reg-meta 002a002a0003000000000001

// ---- declarations / helper functions ----
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

// ---- fragment body (spliced into the generated main()) ----
clip(-abs(saturate(volumeUVW) - volumeUVW));
float3x4 w2m = float3x4(In.texcoord<t0>, In.texcoord<t1>, In.texcoord<t2>);
float3 modelNormal = normalize(mul(worldNormal, make_float3x3(w2m)));
volumeUVW += modelNormal * volumeInfo.invWidth.xyz * volumeInfo.tuning.z;
float4 dirW = tex3D(volumeTexture, volumeUVW);
float3 dir = 2 * dirW.xyz - 1;
//float cw = dot(-dir, modelNormal);
dir = normalize(dir);
float c = dot(-dir, modelNormal);
float w = dirW.w;
float pw = ProjSolidAngle(c, w);
float ks = volumeInfo.tuning.x;
float kc = volumeInfo.tuning.y;
pw = 1 - pow(1 - pw * ks, kc);    
Current.color.rgb = float3(0,0,0);
Current.color.w = pw;
//Current.color.w = pw*32;
