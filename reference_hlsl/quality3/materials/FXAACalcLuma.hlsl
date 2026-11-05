// Material shader: FXAACalcLuma
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
extern uniform sampler map : register(s0);

void main_pixel()
{
    // --- fragment: calcLumaPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 diffuse      = tex2D( map, In.texcoord0.xy ).rgb;
    Current.color.rgba  = float4(diffuse, sqrt(dot(diffuse, float3(0.2126, 0.7152, 0.0722))));
}
