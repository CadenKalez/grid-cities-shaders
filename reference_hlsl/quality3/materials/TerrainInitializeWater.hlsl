// Material shader: TerrainInitializeWater
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
extern uniform sampler textureMapAccumulatedSoilDeposits : register(s1);
float GetSoilSolubility( float soilSolubilityConstant )
{
return soilSolubilityConstant;
}

void main_pixel()
{
    // --- fragment: terrainInitializeWaterPSFragment   (cond 0000000000000000000000000000000000000000000000ff)
    const float param0 = shaderDataTerrainInfo.mParams.x;
    const float param1 = shaderDataTerrainInfo.mParams.y;
    const float param2 = shaderDataTerrainInfo.mParams.z;
    const float param3 = shaderDataTerrainInfo.mParams.w;
    const float paramErosion0 = shaderDataTerrainErosion.mParams.x;
    const float paramErosion1 = shaderDataTerrainErosion.mParams.y;
    const float paramErosion2 = shaderDataTerrainErosion.mParams.z;
    const float paramErosion3 = shaderDataTerrainErosion.mParams.w;
     float v = 1.0-In.texcoord<t0>.w;
    
    float2 uv1 = float2(In.texcoord<t0>.z, v);
    float texSize=param2; //texture resolution of render target passed through as shader data in z component of shaderDataTerrainInfo.mParams
     uv1 +=float2(0.5 * 1.0/texSize, 0.5 * 1.0/texSize);
    //read texel value
    //float texelValue = tex2D(textureMapHeight, uv).r;
    float rainWater=paramErosion1;
    const float modulant=1.0f;
    float startWaterValue=rainWater * modulant; //height value of water
    //initialize amount of dissolved soil.
    float soilSolubility= GetSoilSolubility( param3 );
    //get current deposited material.
    float currentAccumulatedDeposits = tex2D(textureMapAccumulatedSoilDeposits, uv1).r;
    float hardnessModulant=paramErosion2;
    // the more material that has been desposited, the softer and more soluble the soil
    soilSolubility+=(hardnessModulant*currentAccumulatedDeposits);
    //calc max capacity for the amount of water
    float amountSoilToDissolveTotal=startWaterValue* soilSolubility;
    //r = water height g=sediment in water
    float initialSediment=0 ;
    //We wil use this for adding water during simulation
    float sedimentToDeposit=0;
    Current.color = float4(startWaterValue, initialSediment ,  0 , sedimentToDeposit);
}
