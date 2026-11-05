// Shader fragment  [PS slot 211]  terrainHeightPS

// ---- uniform parameters ----
uniform struct { float4 mParams; float4 mScaleAndBias1; float4 mScaleAndBias2; } terrainHeightInfo;   // reg-meta 028f028f0003000000000008

// ---- declarations / helper functions ----
extern uniform sampler HeightMap1 : register(s0);

// ---- fragment body (spliced into the generated main()) ----
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
