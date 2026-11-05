// Material shader: csgThicknessShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: csgQuadVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = In.texcoord<t0>.xyz;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler P1P2 : register(s0);

void main_pixel()
{
    // --- fragment: csgThicknessPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord<t0>.xy;
    float2 p1p2 = tex2D(P1P2, uv).xy;
    float p1 = p1p2.x;
    float p2 = p1p2.y;
    float thickness = max(0, p1 - p2);
    Current.color = float4(thickness, 0, 0, 0);
}
