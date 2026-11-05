// Material shader: InvalidMaterial
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: NullVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position = mul(In.position, modelToClip);
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float pulse;

void main_pixel()
{
    // --- fragment: InvalidMaterialPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4(pulse, 0, 0, 1);
}
