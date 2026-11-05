// Material shader: writeGradient
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: writeGradientPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 start = float3(0.0,0.0,0.0);
    float3 end = float3(255.0/255.0,255.0/255.0,255.0/255.0);
    float3 outColor = lerp(1.0f*start,1.0*end,In.texcoord0.x);
    Current.color.rgba = float4(outColor,1);
}
