// Material shader: brighten
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
extern uniform sampler map : register(s0);

void main_pixel()
{
    // --- fragment: brighten   (cond 0000000000000000000000000000000000000000000000ff)
    float brightenAmount = 0.2;
    Current.color = tex2D(map, In.texcoord0);
    Current.color.rgb = lerp(brightenAmount, 1, Current.color.rgb);
}
