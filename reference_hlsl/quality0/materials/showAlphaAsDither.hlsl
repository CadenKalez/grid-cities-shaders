// Material shader: showAlphaAsDither
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

void main_pixel()
{
    // --- fragment: showAlphaAsDither   (cond 0000000000000000000000000000000000000000000000ff)
    float4 colorIn = tex2D(Sampler<s0>, In.texcoord<t0>.xy);
    const float kMaxDither = 0.7;
    float ditherTarget = saturate(frac((In.vpos.x + In.vpos.y) * 0.5) * 2);
    float ditherAmount = kMaxDither * colorIn.a;
    Current.color = float4(ditherTarget, ditherTarget, ditherTarget, ditherAmount);
}
