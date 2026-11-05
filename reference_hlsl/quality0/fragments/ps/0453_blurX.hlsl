// Shader fragment  [PS slot 453]  blurX

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- declarations / helper functions ----
extern uniform sampler colorBuffer : register(s0);
float2 tapOffset(float s1, float s2, float uBase)
{
float total = s1 + s2;
float left  = s1;
float offset = left / total;
return float2(left + uBase, total);
}
float2 offsetUV(float2 uv, float off)
{
float2 offz = float2(off * screenInfo.z, 0);
return uv + offz;
}

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
const float  kTapStrength[5] = { 0.05 * 1.7, 0.2 * 1.7, 0.5 * 1.7, 0.2 * 1.7, 0.05 * 1.7 };
//const float  kTapStrength[5] = { 0.05, 0.2, 0.5, 0.2, 0.05 };
const float2 kTapLeft = tapOffset(kTapStrength[0], kTapStrength[1], -2);
const float2 kTapRight = tapOffset(kTapStrength[3], kTapStrength[4], 1);
float4 m0 = tex2D(colorBuffer, offsetUV(uv, kTapLeft.x)) * kTapLeft.y;
float4 m1 = tex2D(colorBuffer, uv) * kTapStrength[2];
float4 m2 = tex2D(colorBuffer, offsetUV(uv, kTapRight.x)) * kTapRight.y;
Current.color = m0+m1+m2;
