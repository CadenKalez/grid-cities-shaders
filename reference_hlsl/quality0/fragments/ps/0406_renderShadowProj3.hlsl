// Shader fragment  [PS slot 406]  renderShadowProj3

// ---- uniform parameters ----
uniform float4x4 worldToLight;   // reg-meta 02ac02ac0004000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 rttInfoShadow;   // reg-meta 02be02be0001000000000008

// ---- declarations / helper functions ----
extern uniform sampler lightColorSampler    : register( s12 );
extern uniform sampler lightDepthSampler    : register( s13 );
// This doesn't look good.
// weighted Gaussian on 4x4 with 4 taps
//
// 4x4 gaussian kernal (for fetch4)
//  0.01808  0.04915  0.04915  0.01808
//  0.04915  0.13361  0.13361  0.04915
//  0.04915  0.13361  0.13361  0.04915
//  0.01808  0.04915  0.04915  0.01808
//
// sample positions, weights (for pcf), slightly past texel corners
// (-0.768555, -0.768555), 0.250000
// ( 0.768555, -0.768555), 0.250000
// (-0.768555,  0.768555), 0.250000
// ( 0.768555,  0.768555), 0.250000
// Use a 3x3 kernal with 4 taps
//   and 0.5, 0.25
// tweaking these for a little sharper shadow
static const float2 off = float2( // offset, weight
//0.768555, 0.25
0.5, 0.25
);
float ShadowOrtho(sampler shadowSampler, float4 shadowPos, int style)
{
float shadow = 1;
if (style == 2)
{
// generic single sample
shadow = float(shadowPos.z <= tex2D( shadowSampler, shadowPos.xy).x);
}
else if (style == 3)
{
// generic manual pcf
float3 offset = float3(rttInfoShadow.zw, 0);
// lookup dist
// can do this in one tex2D w/fetch4
float4 dist;
dist.x = tex2D(shadowSampler, shadowPos.xy).x;
dist.y = tex2D(shadowSampler, shadowPos.xy + offset.zy).x;
dist.z = tex2D(shadowSampler, shadowPos.xy + offset.xy).x;
dist.w = tex2D(shadowSampler, shadowPos.xy + offset.xz).x;
dist = greater_equal(dist, shadowPos.z);
// do 'top' left right, and 'bottom' left right in one shot, saving a lerp.
// then do top to bottom lerp.
float2 biweights = frac(shadowPos.xy * rttInfoShadow.xy);
float2 leftRight = lerp(dist.xy, dist.wz, biweights.x);
shadow = lerp(leftRight.x, leftRight.y, biweights.y);
}
else if (style == 4)
{
// fetch4: needs MIPLODBIAS set to GET4
// lookup dist
// can do this in one tex2D w/fetch4
float4 dist = tex2D(shadowSampler, shadowPos.xy).agbr; // swizzled to match bilerp below
dist = greater_equal(dist, shadowPos.z);
// do 'top' left right, and 'bottom' left right in one shot, saving a lerp.
// then do top to bottom lerp.
float2 biweights = frac(shadowPos.xy * rttInfoShadow.xy);
float2 leftRight = lerp(dist.xy, dist.wz, biweights.x);
shadow = lerp(leftRight.x, leftRight.y, biweights.y);
}
else if (style == 5)
{
// fetch4: needs MIPLODBIAS set to GET4
// fetch4 version of weighted pcf
float4 offset = off.x * float4(1,1,0,-1) * rttInfoShadow.zwzw;
float4 texp = shadowPos.xyxy + offset.xyxw;
float4 texm = shadowPos.xyxy - offset.xwxy;
// do four fetch4, and do the bilerp-weighted pcf manually
float4 distx, disty, distz, distw;
distx = tex2D(shadowSampler, texp.xy).agbr; //  1 1
disty = tex2D(shadowSampler, texp.zw).agbr; //  1-1
distz = tex2D(shadowSampler, texm.xy).agbr; // -1 1
distw = tex2D(shadowSampler, texm.zw).agbr; // -1-1
distx = greater_equal(distx, shadowPos.z);
disty = greater_equal(disty, shadowPos.z);
distz = greater_equal(distz, shadowPos.z);
distw = greater_equal(distw, shadowPos.z);
float4 biweightsp = frac(texp * rttInfoShadow.xyxy);
float4 biweightsm = frac(texm * rttInfoShadow.xyxy);
// do pcf
float4 shadowPCF;
float2 leftRight;
leftRight = lerp(distx.xy, distx.wz, biweightsp.x);
shadowPCF.x = lerp(leftRight.x, leftRight.y, biweightsp.y);
leftRight = lerp(disty.xy, disty.wz, biweightsp.z);
shadowPCF.y = lerp(leftRight.x, leftRight.y, biweightsp.w);
leftRight = lerp(distz.xy, distz.wz, biweightsm.x);
shadowPCF.z = lerp(leftRight.x, leftRight.y, biweightsm.y);
leftRight = lerp(distw.xy, distw.wz, biweightsm.z);
shadowPCF.w = lerp(leftRight.x, leftRight.y, biweightsm.w);
shadow = saturate(dot(shadowPCF, make_float4(off.y)));
}
else if (style == 6)
{
// hw pcf
shadow = tex2Dproj( shadowSampler, shadowPos ).x;
}
else if (style == 7)
{
// weighted, four pcf lookups
float4 offset = off.x * float4(1,1,0,-1) * rttInfoShadow.zwzw;
float4 dist;
dist.x = tex2Dproj(shadowSampler, shadowPos + offset.xyzz).x; //  1 1
dist.y = tex2Dproj(shadowSampler, shadowPos + offset.xwzz).x; //  1-1
dist.z = tex2Dproj(shadowSampler, shadowPos - offset.xwzz).x; // -1 1
dist.w = tex2Dproj(shadowSampler, shadowPos - offset.xyzz).x; // -1-1
shadow = saturate(dot(dist, make_float4(off.y))); // just a simple average
}
else if( style == 8 )
{
// receiver plane zbiasing from http://developer.amd.com/media/gpu_assets/Isidoro-ShadowMapping.pdf
// doesn't work.
//Packing derivatives of u,v, and distance to light source w.r.t. screen space x, and y
float4 duvdist_dx = ddx(shadowPos);
float4 duvdist_dy = ddy(shadowPos);
//Invert texture Jacobian and use chain rule to compute ddist/du and ddist/dv
//  |ddist/du| = |du/dx du/dy|-T  * |ddist/dx|
//  |ddist/dv|   |dv/dx dv/dy|      |ddist/dy|
//Multiply ddist/dx and ddist/dy by inverse transpose of Jacobian
float invDet = 1 / ((duvdist_dx.x * duvdist_dy.y) - (duvdist_dx.y * duvdist_dy.x) );
//Top row of 2x2
float2 ddist_duv;
ddist_duv.x = duvdist_dy.y * duvdist_dx.z ; // invJtrans[0][0] * ddist_dx
ddist_duv.x -= duvdist_dx.y * duvdist_dy.z ; // invJtrans[0][1] * ddist_dy
//Bottom row of 2x2
ddist_duv.y = duvdist_dx.x * duvdist_dy.z ;   // invJtrans[1][1] * ddist_dy
ddist_duv.y -= duvdist_dy.x * duvdist_dx.z ;  // invJtrans[1][0] * ddist_dx
ddist_duv *= invDet;
// weighted, four pcf lookups
float4 offset = off.x * float4(1,1,0,-1) * rttInfoShadow.zwzw;
float4 depthOffset = float4(0,1,0,1);
depthOffset.y =  (ddist_duv.x * offset.x) + (ddist_duv.y * offset.y);
depthOffset.w =  (ddist_duv.x * offset.x) + (ddist_duv.y * offset.w);
float4 dist;
dist.x = tex2Dproj(shadowSampler, shadowPos + offset.xyzz + depthOffset.xxyx).x; //  1 1
dist.y = tex2Dproj(shadowSampler, shadowPos + offset.xwzz + depthOffset.xxwx).x; //  1-1
dist.z = tex2Dproj(shadowSampler, shadowPos - offset.xwzz - depthOffset.xxwx).x; // -1 1
dist.w = tex2Dproj(shadowSampler, shadowPos - offset.xyzz - depthOffset.xxyx).x; // -1-1
shadow = saturate(dot(dist, make_float4(off.y))); // just a simple average
}
// plump, smooth, and darken shadow (important!)
shadow *= shadow;
return shadow;
}
float ShadowProj(sampler shadowSampler, float4 shadowPos, int style)
{
float shadow = 1;
if (style == 2)
{
// divide through manually
shadowPos.xyz /= shadowPos.w;
// generic single sample
shadow = float(shadowPos.z <= tex2D( shadowSampler, shadowPos.xy ).x);
}
else if (style == 3)
{
// divide through manually
shadowPos.xyz /= shadowPos.w;
// generic manual pcf
float3 offset = float3(rttInfoShadow.zw, 0);
// lookup dist
// can do this in one tex2D w/fetch4
float4 dist;
dist.x = tex2D(shadowSampler, shadowPos.xy).x;
dist.y = tex2D(shadowSampler, shadowPos.xy + offset.zy).x;
dist.z = tex2D(shadowSampler, shadowPos.xy + offset.xy).x;
dist.w = tex2D(shadowSampler, shadowPos.xy + offset.xz).x;
dist = greater_equal(dist, shadowPos.z);
// do 'top' left right, and 'bottom' left right in one shot, saving a lerp.
// then do top to bottom lerp.
float2 biweights = frac(shadowPos.xy * rttInfoShadow.xy);
float2 leftRight = lerp(dist.xy, dist.wz, biweights.x);
shadow = lerp(leftRight.x, leftRight.y, biweights.y);
}
else if (style == 4)
{
// divide through manually
shadowPos.xyz /= shadowPos.w;
// fetch4: needs MIPLODBIAS set to GET4
// lookup dist
// can do this in one tex2D w/fetch4
float4 dist = tex2D(shadowSampler, shadowPos.xy).agbr; // swizzled to match bilerp below
dist = greater_equal(dist, shadowPos.z);
// do 'top' left right, and 'bottom' left right in one shot, saving a lerp.
// then do top to bottom lerp.
float2 biweights = frac(shadowPos.xy * rttInfoShadow.xy);
float2 leftRight = lerp(dist.xy, dist.wz, biweights.x);
shadow = lerp(leftRight.x, leftRight.y, biweights.y);
}
else if (style == 5)
{
// divide through manually
shadowPos.xyz /= shadowPos.w;
// fetch4: needs MIPLODBIAS set to GET4
// fetch4 version of weighted pcf
float4 offset = off.x * float4(1,1,0,-1) * rttInfoShadow.zwzw;
float4 texp = shadowPos.xyxy + offset.xyxw;
float4 texm = shadowPos.xyxy - offset.xwxy;
// do four fetch4, and do the bilerp-weighted pcf manually
float4 distx, disty, distz, distw;
distx = tex2D(shadowSampler, texp.xy).agbr; //  1 1
disty = tex2D(shadowSampler, texp.zw).agbr; //  1-1
distz = tex2D(shadowSampler, texm.xy).agbr; // -1 1
distw = tex2D(shadowSampler, texm.zw).agbr; // -1-1
distx = greater_equal(distx, shadowPos.z);
disty = greater_equal(disty, shadowPos.z);
distz = greater_equal(distz, shadowPos.z);
distw = greater_equal(distw, shadowPos.z);
float4 biweightsp = frac(texp * rttInfoShadow.xyxy);
float4 biweightsm = frac(texm * rttInfoShadow.xyxy);
// do pcf
float4 shadowPCF;
float2 leftRight;
leftRight = lerp(distx.xy, distx.wz, biweightsp.x);
shadowPCF.x = lerp(leftRight.x, leftRight.y, biweightsp.y);
leftRight = lerp(disty.xy, disty.wz, biweightsp.z);
shadowPCF.y = lerp(leftRight.x, leftRight.y, biweightsp.w);
leftRight = lerp(distz.xy, distz.wz, biweightsm.x);
shadowPCF.z = lerp(leftRight.x, leftRight.y, biweightsm.y);
leftRight = lerp(distw.xy, distw.wz, biweightsm.z);
shadowPCF.w = lerp(leftRight.x, leftRight.y, biweightsm.w);
shadow = saturate(dot(shadowPCF, make_float4(off.y)));
}
else if (style == 6)
{
// hw pcf
shadow = tex2Dproj( shadowSampler, shadowPos ).x;
}
else if (style == 7)
{
// weighted four pcf lookups
float4 offset = off.x * float4(1,1,0,-1) * rttInfoShadow.zwzw * shadowPos.w;
float4 dist;
dist.x = tex2Dproj(shadowSampler, shadowPos + offset.xyzz).x; //  1 1
dist.y = tex2Dproj(shadowSampler, shadowPos + offset.xwzz).x; //  1-1
dist.z = tex2Dproj(shadowSampler, shadowPos - offset.xwzz).x; // -1 1
dist.w = tex2Dproj(shadowSampler, shadowPos - offset.xyzz).x; // -1-1
shadow = saturate(dot(dist, make_float4(off.y))); // just a simple average
}
// plump, smooth, and darken shadow (important!)
shadow *= shadow;
return shadow;
}
void ShadowFade(inout float shadow, float4 wpos)
{
//float deltaZ = worldCameraPosition.z - wpos.z;
//float alpha = shadowControl[0].a;
//float cameraZFade = shadowControl[1].r;
//float3 camPos = worldCameraPosition;
//float p0 = shadowControl[1].g;
//float p1 = shadowControl[1].b;
//float shadowFade = alpha - saturate( deltaZ * p0 + p1 );
//shadow = lerp( 1.0f, shadow, shadowFade );
}
float4 ShadowEvalOrtho(float4 wpos, int style, out float shadow)
{
float4 shadowPos = mul( wpos, worldToLight );
shadow = ShadowOrtho(lightDepthSampler, shadowPos, style);
ShadowFade(shadow, wpos);
return shadowPos;
}
void ShadowEvalProj(float4 wpos, int style, out float shadow)
{
float4 shadowPos = mul( wpos, worldToLight );
shadow = ShadowProj(lightDepthSampler, shadowPos, style);
if (style >= 2)
ShadowFade(shadow, wpos);
}

// ---- fragment body (spliced into the generated main()) ----
float shadow = 1;
ShadowEvalProj(wpos, 3, shadow);
