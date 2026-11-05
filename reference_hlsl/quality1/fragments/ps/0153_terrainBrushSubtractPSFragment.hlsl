// Shader fragment  [PS slot 153]  terrainBrushSubtractPSFragment

// ---- uniform parameters ----
uniform struct { float4 mParams; } shaderDataTerrainInfo;   // reg-meta 029502950001000000000008

// ---- declarations / helper functions ----
extern uniform sampler textureMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
const float param0 = shaderDataTerrainInfo.mParams.x;
const float param1 = shaderDataTerrainInfo.mParams.y;
const float param2 = shaderDataTerrainInfo.mParams.z;
const float param3 = shaderDataTerrainInfo.mParams.w;
//get uv texture coordinate from interpolators
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
//intensity set in swarm
float intensity=param3;
//read texel value
float texelValue = tex2D(textureMap, uv).r;
texelValue*=intensity; //modulate
texelValue*=tex2D(textureMap, uv).a; //alpha channel modulates value
//subtract the value from previously rendered RTT and the texture in brush via alpha blend operation in RT
float finalValue=texelValue;
Current.color = float4(finalValue,finalValue,finalValue,1.0);
