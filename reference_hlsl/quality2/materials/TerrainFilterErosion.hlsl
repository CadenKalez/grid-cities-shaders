// Material shader: TerrainFilterErosion
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
uniform struct { float4 mParams; } shaderDataTerrainErosion;
extern uniform sampler textureMapHeight : register(s0);
extern uniform sampler textureMapWater : register(s1);
extern uniform sampler textureMapAccumulatedSoilDeposits : register(s2);
float GetSoilSolubility( float soilSolubilityConstant )
{
return soilSolubilityConstant;
}

void main_pixel()
{
    // --- fragment: terrainFilterErosionPSFragment   (cond 0000000000000000000000000000000000000000000000ff)
    const float param0 = shaderDataTerrainInfo.mParams.x;
    const float param1 = shaderDataTerrainInfo.mParams.y;
    const float param2 = shaderDataTerrainInfo.mParams.z;
    const float param3 = shaderDataTerrainInfo.mParams.w;
    const float paramErosion0 = shaderDataTerrainErosion.mParams.x;
    const float paramErosion1 = shaderDataTerrainErosion.mParams.y;
    const float paramErosion2 = shaderDataTerrainErosion.mParams.z;
    const float paramErosion3 = shaderDataTerrainErosion.mParams.w;
     float v = 1.0-In.texcoord<t0>.w;
    
    float2 uv1 = float2(In.texcoord<t0>.z, v); //world space projected into uv space.  used to read from previous rtt texture
    float texSize=param2; //texture resolution of render target passed through as shader data in z component of shaderDataTerrainInfo.mParams
     uv1 +=float2(0.5 * 1.0/texSize, 0.5 * 1.0/texSize); //offset fullscreen uvs by 1/2 texel to compensate between screen space pixel center and texel center
    //get current ground and water height
    float currentHeightMapValue = tex2D(textureMapHeight, uv1).r;
    float currentWaterMapValue = tex2D(textureMapWater, uv1).r;
    float soilSolubility= GetSoilSolubility( param3 );
    //get current deposited material.
    float currentAccumulatedDeposits = tex2D(textureMapAccumulatedSoilDeposits, uv1).r;
    currentAccumulatedDeposits = 0.0;
    float hardnessModulant=paramErosion2;
    // the more material that has been desposited, the softer and more soluble the soil
    soilSolubility+=(hardnessModulant*currentAccumulatedDeposits);
    //modulate by water velocity
    float waterVelocity=tex2D(textureMapWater, uv1).b;
    soilSolubility*=waterVelocity; //modulate by water velocity
    //get current sediment (how much soil is already dissolved)
    float currentSediment = tex2D(textureMapWater, uv1).g;
    //calc max capacity for the amount of water
    float amountSoilToDissolveMax=currentWaterMapValue* soilSolubility;
    //calculate how much soil can be dissolved based on how much soil is already  dissolved in the water
    float amountToActuallyDissolve = amountSoilToDissolveMax - currentSediment;
    //erode by lowering height map by the amount of soil dissolved
    float finalHeightValue=currentHeightMapValue - amountToActuallyDissolve;
    //get any precipitated soil from alpha channel of water map texture
    float sedimentToDeposit=tex2D(textureMapWater, uv1).a;
    //add precipitate
    finalHeightValue+=sedimentToDeposit;
    Current.color = float4(finalHeightValue,finalHeightValue,finalHeightValue, 1.0);
}
