// Material shader: T2Border
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (8 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 materialColor;
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

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
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: colorT2SetupVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xy = In.texcoord0.xy;
    Current.color = In.color;
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuseTextureSampler;

void main_pixel()
{
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: applyDiffuseTexture   (cond 0a00000000000000000040000000000000000000000004ff)
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
    Current.color *= diffuseTexture;
    // --- fragment: colorT2SetupPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 color = In.color;
    float2 uv = In.texcoord0.xy;
    // --- fragment: border   (cond 0000000000000000000000000000000000000000000000ff)
    const float kEdge = 0.1f;
    float minUV = min(uv.x,uv.y);
    float minAlpha = smoothstep(kEdge, 0, minUV);
    float maxUV = max(uv.x,uv.y);
    float maxAlpha = smoothstep(1 - kEdge, 1, maxUV);
    Current.color = color;
    Current.color.a *= max(minAlpha,maxAlpha);
}
