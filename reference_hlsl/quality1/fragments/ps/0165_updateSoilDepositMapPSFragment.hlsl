// Shader fragment  [PS slot 165]  updateSoilDepositMapPSFragment

// ---- uniform parameters ----
uniform struct { float4 mParams; } shaderDataTerrainInfo;   // reg-meta 029502950001000000000008

// ---- declarations / helper functions ----
extern uniform sampler textureMapHeight : register(s0);
extern uniform sampler textureMapCurrentDeposit : register(s1);
float GetSoilSolubility( float soilSolubilityConstant )
{
return soilSolubilityConstant;
}

// ---- fragment body (spliced into the generated main()) ----
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
