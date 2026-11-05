// Material shader: globalLightsShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 deferredInfo;
uniform float4 gameInfo;
uniform float4 worldFarCorners[4];

void main_vertex()
{
    // --- fragment: globalLightsVF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 pos              = modelPosition.xy;
    int i                   = int(modelPosition.z);
    float   time            = gameInfo.x;
    float2 screenUV         = pos.xy * deferredInfo.xy + deferredInfo.zw;
    float denom             = 1.0 / ( end - start );
    float4 param            = float4( denom, -start * denom, alpha, 1 - alpha );
    param.xy *= param.xy;
    Current.position        = float4( pos.xy, 0, 1 );
    Current.texcoord<t0>    = float4( screenUV, 0, 0 );
    Current.texcoord<t1>    = float4( pos.xy, 0, 1 );
    Current.texcoord<t2>    = param;
    Current.texcoord<t3>    = worldFarCorners[i];
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 cameraToWorld;
uniform struct { float4 lightDir; float4 color; float4 level; float4 fillColor; float4 fillLevel; } parallel[4];
uniform float4 worldCameraPosition;
uniform float4 screenInfo;
float3 mulq(float3 v, float4 q)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
float unpackDepth( float3 packeddepth )
{
return dot( packeddepth, float3( 1, 1 / 255.0f, 1 / (255.0*255.0) ) );
}
extern uniform sampler      normalSampler   : register( s14 );
extern uniform sampler      depthSampler    : register( s15 );
uniform float4x4 worldToLight;
uniform float4 worldCameraPosition;
uniform float4 rttInfoShadow;
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

void main_pixel()
{
    // --- fragment: globalLightsPF   (cond 0000000000000000000000000000000000000000000000ff)
    float2  screenUV            = In.texcoord0.xy;
    float4  hpos                = In.texcoord1;
    float4  param               = In.texcoord2;
    float3  toWorldFarClip      = In.texcoord3.xyz;
    float4 normalValues = tex2D( normalSampler, screenUV );
    float4 depthValues = tex2D( depthSampler, screenUV );
    float3 normal = normalValues.xyz * 2 - 1;
    normal = normalize( normal );
    float gloss = normalValues.w;
    float depth = unpackDepth( depthValues.xyz );
    float specPow = depthValues.w * 255.0;
    float4 wpos = float4( toWorldFarClip * depth + worldCameraPosition, 1 );
    float3 worldNormal = normal;
    float3 toCamera = worldCameraPosition.xyz - wpos.xyz;
    float  camDist = dot( toCamera, toCamera ); // length( toCamera );
    float3 toCameraNormal = normalize( toCamera ); // / camDist;
    float4 color0 = float4( 0, 0, 0, 0 );
    float4 color1 = float4( 0, 0, 0, 0 );
    float4 color2 = float4( 0, 0, 0, 0 );
    Current.color = float4( 0, 0, 0, 0 );
    // --- fragment: renderShadowOrtho7   (cond 0000000000000000000000000000000000000100000001ff)
    float shadow = 1;
    float4 shadowPos = ShadowEvalOrtho(float4(worldPosition,1), 7, shadow);
    Current.color.rgba = float4(shadow,shadow,shadow,shadow);
    // --- fragment: applyGlossPF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.a *= gloss;
}
