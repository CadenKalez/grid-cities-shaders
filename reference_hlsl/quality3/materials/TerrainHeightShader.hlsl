// Material shader: TerrainHeightShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: terrainHeightQuadVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = In.texcoord<t0>.xyz;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mParams; float4 mScaleAndBias1; float4 mScaleAndBias2; } terrainHeightInfo;
extern uniform sampler HeightMap1 : register(s0);

void main_pixel()
{
    // --- fragment: terrainHeightPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float mapSize = terrainHeightInfo.mParams.x;
    const float spacing = 1.0 / mapSize * terrainHeightInfo.mParams.y;
    const float heightScale = terrainHeightInfo.mParams.z;
    const float normalScale = terrainHeightInfo.mParams.w;
    float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    float height1 = tex2D(HeightMap1, uv).x;  
    height1 *= terrainHeightInfo.mScaleAndBias1.x;  
    height1 *= terrainHeightInfo.mScaleAndBias1.y;  
    height1 += terrainHeightInfo.mScaleAndBias1.z;  
    height1 += terrainHeightInfo.mScaleAndBias1.w;  
    float final = height1;
    final -= terrainHeightInfo.mScaleAndBias1.z;  
    final /= terrainHeightInfo.mScaleAndBias1.x;  
    Current.color = float4(final, 0, 0, 0);
}
