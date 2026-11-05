// Material shader: csgSetupShader
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
extern uniform sampler P1 : register(s0);  
extern uniform sampler P2 : register(s1);

void main_pixel()
{
    // --- fragment: csgSetupPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = float2(In.texcoord<t0>.xy);
    float p1 = tex2D(P1, uv).x;  
    float p2 = tex2D(P2, uv).x;  
    float continued = 0;
    float returned = 0;
    Current.color = float4(p1, p2, continued, returned);
}
