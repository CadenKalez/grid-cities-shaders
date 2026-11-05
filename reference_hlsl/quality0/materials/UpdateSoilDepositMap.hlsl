// Material shader: UpdateSoilDepositMap
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionUV0UV1   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mParams; } shaderDataTerrainInfo;
extern uniform sampler textureMapHeight : register(s0);
extern uniform sampler textureMapCurrentDeposit : register(s1);
float GetSoilSolubility( float soilSolubilityConstant )
{
return soilSolubilityConstant;
}

void main_pixel()
{
    // --- fragment: updateSoilDepositMapPSFragment   (cond 0000000000000000000000000000000000000000000000ff)
    const float param0 = shaderDataTerrainInfo.mParams.x;
    const float param1 = shaderDataTerrainInfo.mParams.y;
    const float param2 = shaderDataTerrainInfo.mParams.z;
    const float param3 = shaderDataTerrainInfo.mParams.w;
     float v = 1.0-In.texcoord<t0>.w;
    
    float2 uv1 = float2(In.texcoord<t0>.z, v);
    float texSize=param2; //texture resolution of render target passed through as shader data in z component of shaderDataTerrainInfo.mParams
     uv1 +=float2(0.5 * 1.0/texSize, 0.5 * 1.0/texSize);
    //read texel value
    float texelHeightValue = tex2D(textureMapHeight, uv1).r;
    float texelOriginalHeightValue = tex2D(textureMapCurrentDeposit, uv1).g;
    float heightDifference=texelHeightValue - texelOriginalHeightValue;
    float accumulatedDeposits=max(0.0, heightDifference);
    Current.color = float4(accumulatedDeposits, texelOriginalHeightValue ,  0 , 0);
}
