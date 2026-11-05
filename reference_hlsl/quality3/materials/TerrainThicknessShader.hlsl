// Material shader: TerrainThicknessShader
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
extern uniform sampler HeightMap1 : register(s0);  
extern uniform sampler HeightMap2 : register(s1);

void main_pixel()
{
    // --- fragment: terrainThicknessPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    float p1 = tex2D(HeightMap1, uv ).x;  
    float p2 = tex2D(HeightMap2, uv ).x;  
    float thickness = saturate(p1-p2);
    Current.color = float4(thickness, 0, 0, 0);
}
