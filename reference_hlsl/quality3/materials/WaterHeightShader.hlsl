// Material shader: WaterHeightShader
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
uniform struct { float4 mParams; float4 mGridSizes; } waterHeightInfo;
extern uniform sampler HeightMap : register(s0);

void main_pixel()
{
    // --- fragment: WaterHeightPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float gridScale = waterHeightInfo.mParams.y;
    const float heightScale = waterHeightInfo.mParams.z;
    const float4 GRID_SIZES = waterHeightInfo.mGridSizes;
    float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    uv *= gridScale;
    float height = 0.0;
    height += tex2D(HeightMap, float2(uv / GRID_SIZES.x) ).x;
    height += tex2D(HeightMap, float2(uv / GRID_SIZES.y) ).y;
    height += tex2D(HeightMap, float2(uv / GRID_SIZES.z) ).z;
    height += tex2D(HeightMap, float2(uv / GRID_SIZES.w) ).w;
    height *= heightScale;
    Current.color = float4(height, 0,0,0);
}
