// Material shader: renderRed
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
extern uniform sampler map : register(s0);

void main_pixel()
{
    // --- fragment: renderRedPS   (cond 0000000000000000000000000000000000000000000000ff)
    half4 diffuse       = tex2D( map, In.texcoord0 );
    diffuse.x = (diffuse.x*256.f + diffuse.y)/256.f;
    Current.color.rgba  = float4(diffuse.xxx, 1);
}
