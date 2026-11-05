// Material shader: lineStencilBackFaceShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: lineStencilBackFaceVF   (cond 0000000000000000000000000000000000000000000000ff)
    float4  pos             = float4( modelPosition.xyz, 1 );
    float4  hpos            = mul( pos, modelToClip );
    Current.position        = hpos;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: lightStencilPF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4( 0, 0, 0, 0 );
}
