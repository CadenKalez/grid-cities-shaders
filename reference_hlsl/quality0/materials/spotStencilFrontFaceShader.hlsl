// Material shader: spotStencilFrontFaceShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 modelToCamera;
uniform float4x4 cameraToClip;
uniform float4 cameraParams[3];

void main_vertex()
{
    // --- fragment: spotStencilFrontFaceVF   (cond 0000000000000000000000000000000000000000000000ff)
    float nearClip          = cameraParams[2].x + 0.01;
    float4 pos              = float4( modelPosition.xyz, 1 );
    float4 vpos             = float4( mul( pos, modelToCamera ), 1 );
    vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
    float4 hpos             = mul( vpos, cameraToClip );
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
