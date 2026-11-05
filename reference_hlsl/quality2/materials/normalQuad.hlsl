// Material shader: normalQuad
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuseTextureSampler;

void main_pixel()
{
    // --- fragment: renderNormalsTexture   (cond 0000000000000000000000000000000000000000000000ff)
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
    float3 normal = diffuseTexture.rgb * 2 - 1; // unpack
    normal = normalize(normal);
    Current.color = float4(normal * 0.5 + 0.5,1);
}
