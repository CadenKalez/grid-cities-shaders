// Shader fragment  [PS slot 160]  terrainWaterMapAddPSFragment

// ---- uniform parameters ----
uniform struct { float4 mParams; } shaderDataTerrainInfo;   // reg-meta 029502950001000000000008
uniform struct { float4 mParams; } shaderDataTerrainErosion;   // reg-meta 029602960001000000000008

// ---- declarations / helper functions ----
extern uniform sampler textureMapWater : register(s0);
extern uniform sampler textureMapWaterNeighbors : register(s1);
extern uniform sampler textureMapSedimentNeighbors : register(s2);
extern uniform sampler textureMapAccumulatedSoilDeposits : register(s3);
float GetSoilSolubility( float soilSolubilityConstant )
{
return soilSolubilityConstant;
}

// ---- fragment body (spliced into the generated main()) ----
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
//read texel value from current water map (has water removed already)
float texelValue = tex2D(textureMapWater, uv1).r;
//get offsets to 4 neighbors
float2 offSetN= float2(0, -1.0f/texSize);
float2 offSetS= float2(0, 1.0f/texSize);
float2 offSetE= float2(1.0f/texSize, 0);
float2 offSetW= float2(-1.0f/texSize, 0);
//get value from neighboring pixels to add to the water height for this pixel
float4 texelValueWaterN = tex2D(textureMapWaterNeighbors, uv1 + offSetN).rgba;
float4 texelValueWaterS = tex2D(textureMapWaterNeighbors, uv1 + offSetS).rgba;
float4 texelValueWaterE = tex2D(textureMapWaterNeighbors, uv1 + offSetE).rgba;
float4 texelValueWaterW = tex2D(textureMapWaterNeighbors, uv1 + offSetW).rgba;
//add the value from water map with water subtracted due to gravity and the water that has come from neigbors that are above
//This is the final amount of water after ingoing and outgoing water for this pixel have been accummulated
float finalWaterValue=texelValue +  texelValueWaterN.g + texelValueWaterS.r + texelValueWaterE.a + texelValueWaterW.b;
//calculate final sediment.  Get value of sediment that this pixel has after subtracting sediment from it (in texture lookup).
//then add the values from neighbors contributing to the sediment at this pixel
float currentSediment=  tex2D(textureMapWater, uv1).g;
//get sediment added from neighbors
float4 texelValueSedimentN=tex2D(textureMapSedimentNeighbors, uv1 + offSetN).rgba;
float4 texelValueSedimentS=tex2D(textureMapSedimentNeighbors, uv1 + offSetS).rgba;
float4 texelValueSedimentE=tex2D(textureMapSedimentNeighbors, uv1 + offSetE).rgba;
float4 texelValueSedimentW=tex2D(textureMapSedimentNeighbors, uv1 + offSetW).rgba;
//final sediment is sum of sediment after water has flown from current pixel + any sediment added from neighbors
float finalSediment=currentSediment + texelValueSedimentN.g + texelValueSedimentS.r + texelValueSedimentE.a + texelValueSedimentW.b;
//evaporate some water.  After evaporation, check if any soil precpitate (ie deposits) should form.
float evaporation=param0;
finalWaterValue= finalWaterValue * (1.0 - evaporation);
float soilSolubility= GetSoilSolubility( param3 );
//get current deposited material.
float currentAccumulatedDeposits = tex2D(textureMapAccumulatedSoilDeposits, uv1).r;
float hardnessModulant=paramErosion2;
// the more material that has been desposited, the softer and more soluble the soil
soilSolubility+=(hardnessModulant*currentAccumulatedDeposits);
//modulate by water velocity
float waterVelocity=tex2D(textureMapWater, uv1).b;
soilSolubility*=waterVelocity; //modulate by water velocity
//calculate the maximum amount of soil this amount of water can hold
float amountSoilToDissolveMax=finalWaterValue* soilSolubility;
//amount of precipitate ie amount of soil to add to heightfield (if any)
float sedimentToDeposit=0;
//if the water is saturated, remove some sediment and deposit it
if ( finalSediment > amountSoilToDissolveMax )
{
sedimentToDeposit=finalSediment - amountSoilToDissolveMax; //amount to precipitate
finalSediment = amountSoilToDissolveMax; //clamp to maximum amount of soil we can dissolve
}
//add rain to total water at this pixel
float rainWater=paramErosion1;
finalWaterValue+=rainWater;
//write out final water and sediment values to red and green channels.   sediment to deposit (ie precipitate is written to a)
Current.color = float4(finalWaterValue , finalSediment , waterVelocity, sedimentToDeposit);
