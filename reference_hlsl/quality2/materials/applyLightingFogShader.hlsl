// Material shader: applyLightingFogShader
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
sampler fogTex : register(s0);

void main_pixel()
{
    // --- fragment: applyLightingFogPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(fogTex, In.texcoord0.xy);
    Current.color.rgb = texColor.rgb;
    Current.color.a = texColor.a;
}
