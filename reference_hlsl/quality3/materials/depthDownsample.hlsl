// Material shader: depthDownsample
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
    // --- fragment: downsampleDepthPS   (cond 0000000000000000000000000000000000000000000000ff)
    // Input depth map contains linear depth values in view space. For my output
    // depth, I need to calculate a non-linear depth.
    float4 depthSample = tex2D( depthMap, In.texcoord<t0>.xy );
    float  depth       = unpackDepth( depthSample.xyz ) * nearFar.y;
    // The linear depth value calculated above is in linear space. Need to
    // transform it by the projection matrix. Normally this could be done
    // with the following code:
    //
    // float4 viewPos = float4( 0.0f, 0.0f, depth, 1.0f );
    // float4 clipPos = mul( viewPos, cameraToClip );
    //
    // depth = clipPos.z / clipPos.w;
    //
    // Which would be 4 dot products and a divide. Simplifying the math by multiplying
    // out the constant values in the viewPos vector give me the following code used
    // below. This should be just a madd and a divide. Also, clipPos.w == depth.
    float clipPosZ = depth * cameraToClip[2].z + cameraToClip[3].z;
    depth = clipPosZ / depth;
    Current.color = depthSample;
    Current.depth = depth;
}
