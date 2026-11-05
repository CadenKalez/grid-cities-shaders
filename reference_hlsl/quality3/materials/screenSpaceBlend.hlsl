// Material shader: screenSpaceBlend
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
sampler2D contourTerrainSampler : register(s8);

void main_pixel()
{
    // --- fragment: blendScreenPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord<t0>;
    float4 terrainColor = tex2D(contourTerrainSampler, uv);
    clip( terrainColor.a < 0.1f ? -1:1 );
    Current.color.a = 0.75;
    Current.color.rgb = terrainColor.rgb;
}
