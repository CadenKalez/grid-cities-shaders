// Material shader: GenericBufferDrawerV3C4FadeShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: copyPositionColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: copyVertexColorPreMultAlphaPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4(In.color.rgb * In.color.a, In.color.a);
    // --- fragment: genericFadePreMultAlphaPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4(Current.color.rgb * 0.7f, Current.color.a * 0.7f);
}
