// Material shader: defaultQuadSetShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 worldToCamera;
uniform float4x4 cameraToClip;

void main_vertex()
{
    // --- fragment: copyUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: defaultQuadSetShaderVS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = Current.texcoord0.xy;
    // get camera space position & offset to quad corner
    float3 cPos = mul(float4(Current.position.xyz, 1), worldToCamera);
    cPos.xy += Current.normal.xy * Current.normal.w; 
    // get clip space position of quad corner
    float4 pPos = mul(float4(cPos, 1), cameraToClip);
    Current.position = pPos;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuse;

void main_pixel()
{
    // --- fragment: defaultQuadSetShaderPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(diffuse, In.texcoord<t0>.xy).xyzw;
    Current.color = Current.color * texColor;
}
