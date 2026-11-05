// Shader fragment  [PS slot 99]  effectSimpleMultiplyAndBlendPF

// ---- uniform parameters ----
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- declarations / helper functions ----
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}

// ---- fragment body (spliced into the generated main()) ----
float colorMultiply = customParams[0].z;
diffuse *= color;
diffuse.rgb *= colorMultiply;
if (customParams[1].x >= 4.0f)  
{
float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
float4 rgbaDepth = tex2D(depthMap, screenUV);
float depth = UnpackDepth(rgbaDepth);
float existingDepth = depth * nearFar.y;
float depthDiff = existingDepth - particleClipPos.w;
float depth_difference_threshold = customParams[1].y;
diffuse.a *= 1-saturate(depthDiff / depth_difference_threshold);
diffuse.a *= saturate(depthDiff / depth_difference_threshold);
}
else if (customParams[1].x >= 3.0f)
{
float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
float4 rgbaDepth = tex2D(depthMap, screenUV);
float depth = UnpackDepth(rgbaDepth);
float existingDepth = depth * nearFar.y;
float depthDiff = abs(existingDepth - particleClipPos.w);
float depth_difference_threshold = customParams[1].y;
diffuse.a *= saturate(depthDiff / depth_difference_threshold);
float normalizeDistanceFromCamera=particleClipPos.w/(nearFar.y * frac(customParams[1].x));
diffuse.a *=( 1.0- normalizeDistanceFromCamera);
}
else if (customParams[1].x >= 2.0f)  
{
float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
float4 rgbaDepth = tex2D(depthMap, screenUV);
float depth = UnpackDepth(rgbaDepth);
float normalizeDistanceFromCamera=particleClipPos.w/ (nearFar.y * frac(customParams[1].x) );
diffuse.a  *=( 1.0- normalizeDistanceFromCamera);
}
else if (customParams[1].x > 0.0f)  
{
float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
float4 rgbaDepth = tex2D(depthMap, screenUV);
float depth = UnpackDepth(rgbaDepth);
float existingDepth = depth * nearFar.y;
float depthDiff = abs(existingDepth - particleClipPos.w);
float depth_difference_threshold = customParams[1].y;
diffuse.a *= saturate(depthDiff / depth_difference_threshold);
}
