// Material shader: renderDepthNonLinear
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 cameraToClip;
uniform float4 nearFar;
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

void main_pixel()
{
    // --- fragment: renderDepthNonLinearPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 depthSample = tex2D( depthMap, In.texcoord<t0>.xy );
    float  depth       = unpackDepth( depthSample.xyz ) * nearFar.y;
    // Input depth map contains linear depth values in view space. Need to
    // calculate a non-linear depth.
    float4 viewPos = float4( 0.0f, 0.0f, depth, 1.0f );
    float4 clipPos = mul( viewPos, cameraToClip );
    depth = clipPos.z / clipPos.w;
    Current.color = float4(depth,depth,depth,depth);
}
