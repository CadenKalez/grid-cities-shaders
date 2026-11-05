// Shader fragment  [PS slot 458]  renderDepthNonLinearPS

// ---- uniform parameters ----
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

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
sampler depthMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 depthSample = tex2D( depthMap, In.texcoord<t0>.xy );
float  depth       = unpackDepth( depthSample.xyz ) * nearFar.y;
// Input depth map contains linear depth values in view space. Need to
// calculate a non-linear depth.
float4 viewPos = float4( 0.0f, 0.0f, depth, 1.0f );
float4 clipPos = mul( viewPos, cameraToClip );
depth = clipPos.z / clipPos.w;
Current.color = float4(depth,depth,depth,depth);
