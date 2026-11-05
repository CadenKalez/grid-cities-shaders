// Material shader: road_demolish_tile
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 worldToClip;

void main_vertex()
{
    // --- fragment: worldToClipSpaceVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position = mul(float4(Current.position.xyz, 1), worldToClip);
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: roadDemolishTilePS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb = In.color.rgb * In.color.a;
    Current.color.a = In.color.a;
}
