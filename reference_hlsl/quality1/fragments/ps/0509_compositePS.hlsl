// Shader fragment  [PS slot 509]  compositePS

// ---- uniform parameters ----
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000

// ---- declarations / helper functions ----
float3 mulq(float3 v, float4 q)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
float unpackDepth( float3 packeddepth )
{
return dot( packeddepth, float3( 1, 1 / 255.0f, 1 / (255.0*255.0) ) );
}
sampler effectsLowResMap : register(s0);
sampler depthMap         : register(s1);
sampler depthLowResMap   : register(s2);
float getNonLinearDepth( sampler depthMap, float2 uv )
{
float4 depthSample = tex2D( depthMap, uv );
float  depth       = unpackDepth( depthSample.xyz ) * nearFar.y;
return depth;
}
static const float kEpsilon = 0.00000001f;

// ---- fragment body (spliced into the generated main()) ----
// Proper composite!
float  depthHiRes;
float4 depthLoRes;
float4 depthWeights;
float4 loResCol[4];
// sample depths, compute depth weights
// hires depth
depthHiRes = getNonLinearDepth( depthMap, In.texcoord<t0>.xy );
// lores uv's
float2 uv0 = In.texcoord<t1>.xy;
float2 uv1 = In.texcoord<t1>.zw;
float2 uv2 = In.texcoord<t2>.xy;
float2 uv3 = In.texcoord<t2>.zw;
// lores depths
depthLoRes.x = getNonLinearDepth( depthLowResMap, uv0 );
depthLoRes.y = getNonLinearDepth( depthLowResMap, uv1 );
depthLoRes.z = getNonLinearDepth( depthLowResMap, uv2 );
depthLoRes.w = getNonLinearDepth( depthLowResMap, uv3 );
// lores colours
loResCol[0] = tex2D( effectsLowResMap, uv0 );
loResCol[1] = tex2D( effectsLowResMap, uv1 );
loResCol[2] = tex2D( effectsLowResMap, uv2 );
loResCol[3] = tex2D( effectsLowResMap, uv3 );
// depth difference hires to all lores depths
float4 depthDiff = abs( make_float4(depthHiRes) - depthLoRes.xyzw );
// weight the depth differences (smaller difference => larger weight)
depthWeights = 1.0f / max( depthDiff, kEpsilon );
float  totalWeight = 0;
float4 upsampled   = float4(0, 0, 0, 0);
// get bilinear weights
float4 bilinWeights;
// Calculate bilinear weights
bilinWeights = ( In.texcoord<t0>.xyxy - uv0.xyxy ) * ( renderTargetInfo0.xyxy * 0.5f );
bilinWeights.xy = 1.0f - bilinWeights.xy;
bilinWeights = bilinWeights.xzxz * bilinWeights.yyww;
// Combine the two sets of weights
float4 combinedWeights = depthWeights * bilinWeights;
totalWeight = dot( combinedWeights, float4( 1.0f, 1.0f, 1.0f, 1.0f ) );
combinedWeights /= totalWeight;
// sum lores colour pixels by weight
upsampled = loResCol[0] * combinedWeights.xxxx;
upsampled = loResCol[1] * combinedWeights.yyyy + upsampled;
upsampled = loResCol[2] * combinedWeights.zzzz + upsampled;
upsampled = loResCol[3] * combinedWeights.wwww + upsampled;
Current.color = upsampled;
