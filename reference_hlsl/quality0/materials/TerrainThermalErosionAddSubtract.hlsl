// Material shader: TerrainThermalErosionAddSubtract
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
    // --- fragment: terrainThermalErosionAddSubtractPSFragment   (cond 0000000000000000000000000000000000000000000000ff)
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
    //read texel values from height map and water map
    float texelValueHeight = tex2D(textureMapHeight, uv1).r;
    //get maximum slope allowed for the erosion.  if we exceed this slope, do not transport soil
    float maxSlope=paramErosion0;
    // get cutoff elevation above which no erosion occurs
    float cutoffElevation=paramErosion1;
    //get value which gets added to erosion (if material moves).  This has no basis in material transport and is simply a tuning parameter.
    float massBalance=paramErosion3;
    //total height at pixel
    float h=texelValueHeight ;
    float talus= param1; //slope cutoff
    float dtotal=0; //total height difference of neighbors that are below current pixel
    float dmax=0;
    //get offsets to 4 neighbors N, S, E, W
    float2 offSetN= float2(0, -1.0f/texSize);
    float2 offSetS= float2(0, 1.0f/texSize);
    float2 offSetE= float2(1.0f/texSize, 0);
    float2 offSetW= float2(-1.0f/texSize, 0);
    float4 texelValueHeightNSEW;
    texelValueHeightNSEW.x = tex2D(textureMapHeight, uv1 + offSetN).r; //get N neighbor
    texelValueHeightNSEW.y = tex2D(textureMapHeight, uv1 + offSetS).r; //Get S neighbor
    texelValueHeightNSEW.z = tex2D(textureMapHeight, uv1 + offSetE).r; //Get E neighbor
    texelValueHeightNSEW.w = tex2D(textureMapHeight, uv1 + offSetW).r; //Get W neighbor
    float4 diNSEW = float4(h,h,h,h) - texelValueHeightNSEW;
    float4 diGTtalus = diNSEW > float4(talus,talus,talus,talus) ? float4(1,1,1,1) : float4(0,0,0,0);
    float4 diLTmaxSlope = diNSEW < float4(maxSlope,maxSlope,maxSlope,maxSlope) ? float4(1,1,1,1) : float4(0,0,0,0);
    float  heightLTcutoff = texelValueHeight<cutoffElevation ? 1.0f : 0.0f;
    float4 allConditions = diGTtalus * diLTmaxSlope * heightLTcutoff;
    const float4 allOne = float4(1,1,1,1);
    float4 dmax4 = diNSEW * allConditions;
    dtotal = dot(allOne,dmax4);
    float2 dmax2 = max(dmax4.xy, dmax4.zw);
    dmax = max (dmax2.x, dmax2.y);
    float soilSolubility=  param3 ;
    //get current deposited material.
    float currentAccumulatedDeposits = tex2D(textureMapAccumulatedSoilDeposits, uv1).r;
    float hardnessModulant=paramErosion2;
    // the more material that has been desposited, the softer and more soluble the soil
    soilSolubility+=(hardnessModulant*currentAccumulatedDeposits);
        
    float factor = soilSolubility * (dmax - talus);
    float4 addedNSEW =  float4(factor,factor,factor,factor) * (diNSEW/dtotal);
    addedNSEW += float4(massBalance, massBalance, massBalance, massBalance);
    addedNSEW *= allConditions;
    float totalRemoved = dot(allOne,addedNSEW);
    //write the total soil removed ie given to neighbors into render target r channel
    Current.color = float4(totalRemoved, 0 ,0, 0);
    //write the amount of soil moved to nearest neighborrs
    Current.color1 = addedNSEW;
}
