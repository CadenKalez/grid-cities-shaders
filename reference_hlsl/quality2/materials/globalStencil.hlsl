// Material shader: globalStencil
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 shadowFrustumInfo;
uniform float4x4 cameraToClip;

void main_vertex()
{
    // --- fragment: stencilToClip   (cond 0000000000000000000000000000000000000000000000ff)
    float4 pos              = float4( modelPosition.xyz, 1 );
    pos.z = shadowFrustumInfo.z;
    float4 hpos             = mul( pos, cameraToClip );
    hpos.xy = modelPosition.xy * hpos.w;
    Current.position        = hpos;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: simpleDrawWhite   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgba  = float4(1,0,0,.90);
}
