// Shader fragment  [PS slot 466]  applyDoFPS

// ---- uniform parameters ----
uniform struct { float4 dofFocusPlane; float4 dofFocusDistances; float4 dofLerpScale;float4 dofLerpBias;} tiltShiftDOFInfo;   // reg-meta 02a502a50004000000000008
uniform struct { float4 mTargetSizes; float4 mViewportSizes; float4 mNearFar;} cameraParams;   // reg-meta 022202220003000000004000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- declarations / helper functions ----
extern uniform sampler blurredCoC : register(s0);
extern uniform sampler depthTex : register(s13);
extern uniform sampler colorTex : register(s14);
extern uniform sampler miniColorTex : register(s15);
float4 tex2Doffset( sampler s, float2 texCoord, float2 offset )
{
return tex2D( s, texCoord + offset * screenInfo.zw );
}
float4 GetSmallBlurSample( sampler s, float2 texCoord )
{
float4 sum;
const float weight = 4.0 / 16;
sum = float4(0, 0, 0, 0);  // Unblurred sample done by alpha blending
sum += weight * tex2Doffset( s, texCoord, float2(+0.5, -1.5) );
sum += weight * tex2Doffset( s, texCoord, float2(-1.5, -0.5) );
sum += weight * tex2Doffset( s, texCoord, float2(-0.5, +1.5) );
sum += weight * tex2Doffset( s, texCoord, float2(+1.5, +0.5) );
return sum;
}
float4 GetSmallerBlurSample( sampler s, float2 texCoord )
{
float4 sum;
const float weight = 4.0 / 16;
sum = float4(0, 0, 0, 0);  // Unblurred sample done by alpha blending
sum += weight * tex2Doffset( s, texCoord, 2.0f*float2(+0.5, -1.5) );
sum += weight * tex2Doffset( s, texCoord, 2.0f*float2(-1.5, -0.5) );
sum += weight * tex2Doffset( s, texCoord, 2.0f*float2(-0.5, +1.5) );
sum += weight * tex2Doffset( s, texCoord, 2.0f*float2(+1.5, +0.5) );
return sum;
}
float4 GetSmallestBlurSample( sampler s, float2 texCoord )
{
float4 sum;
const float weight = 4.0 / 16;
sum = float4(0, 0, 0, 0);  // Unblurred sample done by alpha blending
sum += weight * tex2Doffset( s, texCoord, 2.0f*2.0f*float2(+0.5, -1.5) );
sum += weight * tex2Doffset( s, texCoord, 2.0f*2.0f*float2(-1.5, -0.5) );
sum += weight * tex2Doffset( s, texCoord, 2.0f*2.0f*float2(-0.5, +1.5) );
sum += weight * tex2Doffset( s, texCoord, 2.0f*2.0f*float2(+1.5, +0.5) );
return sum;
}
float4 InterpolateDof( float3 small, float3 med, float3 large, float t )
{
float4 weights;
float3 color;
float  alpha;
// Efficiently calculate the cross-blend weights for each sample.
// Let the unblurred sample to small blur fade happen over distance
// d0, the small to medium blur over distance d1, and the medium to
// large blur over distance d2, where d0 + d1 + d2 = 1.
// dofLerpScale = float4( -1 / d0, -1 / d1, -1 / d2, 1 / d2 );
// dofLerpBias = float4( 1, (1  d2) / d1, 1 / d2, (d2  1) / d2 );
weights = saturate( t * tiltShiftDOFInfo.dofLerpScale + tiltShiftDOFInfo.dofLerpBias );
weights.yz = min( weights.yz, 1 - weights.xy );
//Unblurred sample with weight "weights.x" done by alpha blending
color = weights.y * small + weights.z * med + weights.w * large;
alpha = dot( weights.yzw, float3( 1.0, 1.0, 1.0 ) );
return float4( color, alpha );
}
float UnpackDepth(float4 rgbaDepth)
{
return (tiltShiftDOFInfo.dofFocusPlane.z * (cameraParams.mNearFar.y*(rgbaDepth.x*255.0 + rgbaDepth.y + rgbaDepth.z/255.0)/255.0)) - tiltShiftDOFInfo.dofFocusPlane.w;
// todo:  translate to world space/whatever, then find dist to arbitrary FocalPlane
}

// ---- fragment body (spliced into the generated main()) ----
float farCoc;
float coc;
float4 small = GetSmallBlurSample( colorTex, In.texcoord0.xy );
float4 med = GetSmallerBlurSample( blurredCoC, In.texcoord0.xy );
float4 large = GetSmallestBlurSample( miniColorTex, In.texcoord0.xy );
float nearCoc = large.a;
float depth = UnpackDepth(tex2D( depthTex, In.texcoord0.xy ));
// dofEqFar.z is the ratio of the far to the near blur radius.
farCoc = saturate( tiltShiftDOFInfo.dofFocusDistances.z * depth + tiltShiftDOFInfo.dofFocusDistances.w );
coc = max( nearCoc, farCoc );
// todo:  multiply by something to change the ratio of far to near blur radius?
// something like: coc = max( nearCoc, farCoc * nearToFarRatio );
Current.color.rgba = InterpolateDof( small.rgb, med.rgb, large.rgb, coc );
//Current.color.rgb = float3(coc,coc,coc);
//Current.color.a = 1.0f;
