// Material shader: roadGuideDashedShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: copyUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler textureSampler : register(s0);

void main_pixel()
{
    // --- fragment: roadGuideDashedPS   (cond 0000000000000000000000000000000000000000000000ff)
    // NB: We expect the UV coords to have been scaled before being passed in as part
    // of the vertex data.
    float4 texColor = tex2D(textureSampler, In.texcoord0.xy);
    // Adjust opacity
    Current.color = In.color * texColor * 0.50f;
    Current.color.a = texColor.a * 0.50f;
}
