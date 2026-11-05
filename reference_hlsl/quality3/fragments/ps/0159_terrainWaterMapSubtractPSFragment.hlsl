// Shader fragment  [PS slot 159]  terrainWaterMapSubtractPSFragment

// ---- uniform parameters ----
uniform struct { float4 mParams; } shaderDataTerrainInfo;   // reg-meta 029502950001000000000008
uniform struct { float4 mParams; } shaderDataTerrainErosion;   // reg-meta 029602960001000000000008

// ---- declarations / helper functions ----
extern uniform sampler textureMapHeight : register(s0);
extern uniform sampler textureMapWater : register(s1);
extern uniform sampler textureMapAccumulatedSoilDeposits : register(s2);
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
//read texel values from height map and water map
float texelValueHeight = tex2D(textureMapHeight, uv1).r;
float currentWaterMapValue = tex2D(textureMapWater, uv1).r;
//total height at pixel
float h=texelValueHeight + currentWaterMapValue;
float talus= param1; //slope cutoff
float dtotal=0; //total height difference of neighbors that are below current pixel
float heightTotal=0; //total height of neighbors that are below current pixel
float numBelow=0; //number of pixels at lower elevation
//get offsets to 4 neighbors N, S, E, W
float2 offSetN= float2(0, -1.0f/texSize);
float2 offSetS= float2(0, 1.0f/texSize);
float2 offSetE= float2(1.0f/texSize, 0);
float2 offSetW= float2(-1.0f/texSize, 0);
//get N  neighbor
float texelValueHeightN = tex2D(textureMapHeight, uv1 + offSetN).r;
float texelValueWaterN = tex2D(textureMapWater, uv1 + offSetN).r;
float hN=texelValueHeightN + texelValueWaterN;
float diN=h - hN;
if (diN > talus)
{
numBelow++;
dtotal = dtotal + diN;
heightTotal+=hN;
}
//Get S neighbor
float texelValueHeightS = tex2D(textureMapHeight, uv1+ offSetS).r;
float texelValueWaterS = tex2D(textureMapWater, uv1+offSetS).r;
float hS=texelValueHeightS + texelValueWaterS;
float diS=h - hS;
if (diS > talus)
{
numBelow++;
dtotal = dtotal + diS;
heightTotal+=hS;
}
//Get E neighbor
float texelValueHeightE = tex2D(textureMapHeight, uv1+ offSetE).r;
float texelValueWaterE = tex2D(textureMapWater, uv1+offSetE).r;
float hE=texelValueHeightE + texelValueWaterE;
float diE=h - hE;
if (diE > talus)
{
numBelow++;
dtotal = dtotal + diE;
heightTotal+=hE;
}
//Get W neighbor
float texelValueHeightW = tex2D(textureMapHeight, uv1+ offSetW).r;
float texelValueWaterW = tex2D(textureMapWater, uv1+offSetW).r;
float hW=texelValueHeightW + texelValueWaterW;
float diW = h - hW;
if (diW > talus)
{
numBelow++;
dtotal = dtotal + diW;
heightTotal+=hW;
}
//calculate the average height of all surrounding neighbors that are lower than current pixel
float avgHeight=0;
if ( numBelow > 0)
{
avgHeight=(heightTotal/numBelow);
}
//calculate the difference between the current total height of pixel and avg total height of neighbors below it
float deltaA=h - avgHeight;
float w=currentWaterMapValue;
float  addedN = 0;
if (  diN > talus)
{
addedN=min(w, deltaA)  * (diN/dtotal) ;
}
float  addedS = 0;
if (  diS > talus)
{
addedS=min(w, deltaA)  * (diS/dtotal) ;
}
float  addedE = 0;
if (  diE > talus)
{
addedE=min(w, deltaA)  * (diE/dtotal) ;
}
float  addedW = 0;
if (  diW > talus)
{
addedW=min(w, deltaA)  * (diW/dtotal) ;
}
//clamp for sanity check
addedN=max(0.0, addedN);
addedS=max(0.0, addedS);
addedE=max(0.0, addedE);
addedW=max(0.0, addedW);
//calculate total amount of water that has flowed to the neighboring pixels
float totalWaterRemoved=addedN + addedS + addedE+ addedW;
//calculate final value of water after we have removed it from current pixel and given it to neighbors below
float finalWaterValue=currentWaterMapValue - totalWaterRemoved;
finalWaterValue=max(0.0, finalWaterValue );
//calculate new velocity of water based on previous velocity
float waterModulant=paramErosion0; //set from swarm script
float currentWaterVelocity=tex2D(textureMapWater, uv1).b;
float waterVelocity = currentWaterVelocity + (dtotal*waterModulant); //get new velocity
waterVelocity-= waterVelocity * 0.01f; //deacclerate due to friction
waterVelocity=saturate( waterVelocity ); //clamp
float soilSolubility= GetSoilSolubility( param3 );
//get current deposited material.
float currentAccumulatedDeposits = tex2D(textureMapAccumulatedSoilDeposits, uv1).r;
float hardnessModulant=paramErosion2;
// the more material that has been desposited, the softer and more soluble the soil
soilSolubility+=(hardnessModulant*currentAccumulatedDeposits);
soilSolubility*=waterVelocity; //modulate by water velocity
//get current sediment dissolved from last update
float currentSediment=tex2D(textureMapWater, uv1).g;
//calc max capacity of dissolved sediment for the amount of water currently at pixel
float amountSoilToDissolveMax=currentWaterMapValue* soilSolubility;
//calculate how amount of soil that can be absorbed based on current amount of water and how much is already dissolved
float amountToActuallyDissolve = amountSoilToDissolveMax - currentSediment;
//get the sediment dissolved in current water and add soil that has been dissolved
float finalSediment=currentSediment + amountToActuallyDissolve;
//calculate the amount of sediment at this pixel after some sediment as been removed  (if water has flown to neighbors)
if ( totalWaterRemoved > 0 )
{
float sedimentRemoved= currentSediment *( totalWaterRemoved/currentWaterMapValue );
finalSediment-=sedimentRemoved;
}
//write final water height after subtracting water that has been removed into r channel,
//write sediment  after water removal into g channel.  the final step of the simulation will add any sediment flowing into this pixel from neighboring pixels
Current.color = float4(finalWaterValue, finalSediment , waterVelocity , 0);
//calculate the amount of sediment to add to each neighbor.  This is simply the percentage of water that has been added to a neighbor multiplied
//by the current sediment dissolved at current pixel
float addedSedimentN= ( w>0) ? (addedN/w) * currentSediment : 0;
float addedSedimentS= ( w>0) ? (addedS/w) * currentSediment : 0;
float addedSedimentE= ( w>0) ? (addedE/w) * currentSediment : 0;
float addedSedimentW= ( w>0) ? (addedW/w) * currentSediment : 0;
//write water height to add to each neighbor
Current.color1 = float4(addedN,addedS,addedE,addedW);
//write out sediment to add to each neighbor
Current.color2 = float4(addedSedimentN,addedSedimentS,addedSedimentE,addedSedimentW);
