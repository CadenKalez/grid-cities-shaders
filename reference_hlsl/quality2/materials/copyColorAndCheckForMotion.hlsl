// Material shader: copyColorAndCheckForMotion
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler currentColorTexture : register(s1);
extern uniform sampler oldColorTexture : register(s2);

void main_pixel()
{
    // --- fragment: checkForMotionPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float kColorErrFactor = 256.0;
    float4 curColor = tex2D(currentColorTexture, In.texcoord0.xy);
    float4 oldColor = tex2D(oldColorTexture, In.texcoord0.xy);
    float3 colorDiff = oldColor.xyz - curColor.xyz;
    float  colorErr  = dot(colorDiff, colorDiff) * kColorErrFactor;
    Current.color = float4(curColor.xyz, colorErr);
}
