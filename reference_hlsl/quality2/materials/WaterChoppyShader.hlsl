// Material shader: WaterChoppyShader
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
uniform struct { float4 mParams; float4 mGridSizes; } waterChoppyInfo;
extern uniform sampler ChoppyMap1 : register(s0);
extern uniform sampler ChoppyMap2 : register(s1);

void main_pixel()
{
    // --- fragment: WaterChoppyPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float gridScale = waterChoppyInfo.mParams.y;
    const float choppyScale = waterChoppyInfo.mParams.z;
    const float choppyHeight = waterChoppyInfo.mParams.w;
    const float4 GRID_SIZES = waterChoppyInfo.mGridSizes;
    float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    uv *= gridScale;
    float2 choppy = float2(0.0, 0.0);
    choppy += tex2D(ChoppyMap1, float2(uv / GRID_SIZES.x) ).xy;
    choppy += tex2D(ChoppyMap1, float2(uv / GRID_SIZES.y) ).zw;
    choppy += tex2D(ChoppyMap2, float2(uv / GRID_SIZES.z) ).xy;
    choppy += tex2D(ChoppyMap2, float2(uv / GRID_SIZES.w) ).zw;
    choppy *= choppyScale;
    float3 C = normalize(float3(-choppy.x, choppyHeight, -choppy.y));
    Current.color = float4(C.x, C.y, C.z, 0);
}
