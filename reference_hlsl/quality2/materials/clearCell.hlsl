// Material shader: clearCell
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColor   (cond 0000000000000000000000000000000000000000000000ff)
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: clearCellPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color  = In.color;
    Current.color1 = In.color;
}
