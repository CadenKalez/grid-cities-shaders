// Shader fragment  [PS slot 499]  edgeBlur5PS

// ---- declarations / helper functions ----
extern uniform sampler rtEdge : register(s0);
// This gives the kernel values for a pie wedge
// of the 5x5 kernel; the values are copied to all 8 wedges:
//     +---+
//     |\|/|  (@ signs represent the wedge defined
//     +-@-+   in kTapSrc below)
//     |/@@|
//     +-@@@
//
// This first value is the amount of "edge width" required to
// affect the pixel at all, the second is the amount to scale
// the remaining edge width by.
//
// For example, {0.0, 5.0} for the center pixel means that
// any source value over 0.0 should affect that pixel, and
// that a value of 0.2 or greater will make the pixel fully
// opaque.  (0.2 * 5.0 = 1.0).
static const float2 kTapSrc[] = {
{ 0.0, 5.0 },// 0
{ 0.2, 3.0 },// 1
{ 0.4, 0.7 },// 2
{ 0.6, 2.0 },// 3
{ 0.9, 1.0 },// 4
{ 0.7, 1.0 },// 5
};
static const float3 kCutoff[] = {
{ kTapSrc[3].x, kTapSrc[1].x, kTapSrc[0].x },
{ kTapSrc[4].x, kTapSrc[2].x, kTapSrc[1].x },
{ kTapSrc[5].x, kTapSrc[4].x, kTapSrc[3].x },
};
static const float3 kWeight[] = {
{ kTapSrc[3].y, kTapSrc[1].y, kTapSrc[0].y },
{ kTapSrc[4].y, kTapSrc[2].y, kTapSrc[1].y },
{ kTapSrc[5].y, kTapSrc[4].y, kTapSrc[3].y },
};
void AddFour(in out float4 color, float2 tex0, float2 tex1, float2 tex2, float2 tex3, float4 cutoff, float4 weight)
{
// do four ops at a time
float4 sample0, sample1, sample2, sample3;
sample0 = tex2D(rtEdge, tex0);
sample1 = tex2D(rtEdge, tex1);
sample2 = tex2D(rtEdge, tex2);
sample3 = tex2D(rtEdge, tex3);
float4 alpha;
alpha = float4(sample0.a, sample1.a, sample2.a, sample3.a); // 4 moves
alpha = saturate(alpha - cutoff) * weight;
color.rgb += sample0.rgb * alpha.x;
color.rgb += sample1.rgb * alpha.y;
color.rgb += sample2.rgb * alpha.z;
color.rgb += sample3.rgb * alpha.w;
color.a += dot(alpha, 1);
}

// ---- fragment body (spliced into the generated main()) ----
float4 tex0          = In.texcoord0;
float4 tex1          = In.texcoord1;
float4 tex2          = In.texcoord2;
float4 tex3          = In.texcoord3;
float4 tex4          = In.texcoord4;
float4 tex5          = In.texcoord5;
float4 tex6          = In.texcoord6;
float4 tex7          = In.texcoord7;
float4 tex8          = In.color;
float4 tex9          = In.color1;
// one leftover in corner
float4 sample = tex2D(rtEdge, tex9.zw);
float  alpha  = saturate(sample.a - kCutoff[2].x) * kWeight[2].x;
float4 color = float4(sample.rgb,1) * alpha;
// one row down
AddFour(color, tex5.zw, tex6.zw, tex7.zw, tex8.zw, kCutoff[2].xyzy, kWeight[2].xyzy);
// four across
AddFour(color, tex0.xw, tex0.yw, tex0.zw, tex5.yw, kCutoff[2].xyzy, kWeight[2].xyzy);
AddFour(color, tex1.xw, tex1.yw, tex1.zw, tex6.yw, kCutoff[1].xyzy, kWeight[1].xyzy);
AddFour(color, tex2.xw, tex2.yw, tex2.zw, tex7.yw, kCutoff[0].xyzy, kWeight[0].xyzy);
AddFour(color, tex3.xw, tex3.yw, tex3.zw, tex8.yw, kCutoff[1].xyzy, kWeight[1].xyzy);
AddFour(color, tex4.xw, tex4.yw, tex4.zw, tex9.yw, kCutoff[2].xyzy, kWeight[2].xyzy);
color.rgb /= color.a;
Current.color = color;
