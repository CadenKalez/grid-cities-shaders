// Material shader: generic2D
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (7 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 materialColor;
uniform float4 screenInfo;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: copyVertexColor   (cond 0000000000000000000008000000000000000200000002ff)
    // --- fragment: whiteVertexColor   (cond 0000000000000000000000000000000000000200000002ff)
    Current.color = float4(1, 1, 1, 1);
    // --- fragment: applyMaterialColor   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= materialColor;
    // --- fragment: copyUV0   (cond 0a00000000000000000040000000000000000000000004ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: screenSpacePosition   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position.xy *= screenInfo.zw; //  * float2(-1, 2);
    Current.position.xy -= float2(0.5, 0.5);
    Current.position.xy *= float2(2, -2);
    Current.position.zw = float2(0, 1);
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuseTextureSampler;

void main_pixel()
{
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: applyDiffuseTexture   (cond 0a00000000000000000040000000000000000000000004ff)
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
    Current.color *= diffuseTexture;
}
