// Material shader: debugPointShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4x4 worldToClip;

void main_vertex()
{
    // --- fragment: debugPointVF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 pos              = float4( modelPosition.xyz * deferredLight.position.w + deferredLight.position.xyz, 1 );
    float4 hpos             = mul( pos, worldToClip );
    Current.position        = hpos;
    Current.color           = float4( deferredLight.diffColor.rgb, 1 );
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: debugPointPF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = In.color;
}
