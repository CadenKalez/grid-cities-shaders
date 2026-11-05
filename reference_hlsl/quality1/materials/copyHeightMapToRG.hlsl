// Material shader: copyHeightMapToRG
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
sampler heightMapSampler : register(s14);

void main_pixel()
{
    // --- fragment: copyHeightMapToRG   (cond 0000000000000000000000000000000000000000000000ff)
    float baseHeight = tex2D(heightMapSampler, In.texcoord<t0>.xy).x;
    float final = baseHeight * 255.0;
    Current.color.rgba = float4(floor(final) / 255.0, floor(frac(final)*255.0) / 255.0, 0, 0);
}
