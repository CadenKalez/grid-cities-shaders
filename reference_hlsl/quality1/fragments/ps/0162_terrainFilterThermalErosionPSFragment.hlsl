// Shader fragment  [PS slot 162]  terrainFilterThermalErosionPSFragment

// ---- uniform parameters ----
uniform struct { float4 mParams; } shaderDataTerrainInfo;   // reg-meta 029502950001000000000008

// ---- declarations / helper functions ----
extern uniform sampler textureMapHeight : register(s0);
extern uniform sampler textureMapSubtract : register(s1);
extern uniform sampler textureMapAdd : register(s2);
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

float2 uv1 = float2(In.texcoord<t0>.z, v); //world space projected into uv space.  used to read from previous rtt texture
float texSize=param2; //texture resolution of render target passed through as shader data in z component of shaderDataTerrainInfo.mParams
 uv1 +=float2(0.5 * 1.0/texSize, 0.5 * 1.0/texSize); //offset fullscreen uvs by 1/2 texel to compensate between screen space pixel center and texel center
//get current ground and water height
float currentHeightMapValue = tex2D(textureMapHeight, uv1).r;
float subtractValue = tex2D(textureMapSubtract, uv1).r;  //amount to subtratc from this pixel
//get nearest neighbors and get the amount to add from them
//get offsets to 4 neighbors
float2 offSetN= float2(0, -1.0f/texSize);
float2 offSetS= float2(0, 1.0f/texSize);
float2 offSetE= float2(1.0f/texSize, 0);
float2 offSetW= float2(-1.0f/texSize, 0);
//get value from neighboring pixels to add to the  height for this pixel
float4 texelValueDepositN = tex2D(textureMapAdd, uv1 + offSetN).rgba;
float4 texelValueDepositS = tex2D(textureMapAdd, uv1 + offSetS).rgba;
float4 texelValueDepositE = tex2D(textureMapAdd, uv1 + offSetE).rgba;
float4 texelValueDepositW = tex2D(textureMapAdd, uv1 + offSetW).rgba;
float finalheight=currentHeightMapValue - subtractValue  +  texelValueDepositN.g + texelValueDepositS.r + texelValueDepositE.a + texelValueDepositW.b;
Current.color = float4(finalheight,finalheight,finalheight, 1.0);
