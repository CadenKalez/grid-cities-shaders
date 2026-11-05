// Material shader: clearZMax
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: setZMax   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position.z = 0 * Current.position.w;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: setZMax   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgba = 1;
}
