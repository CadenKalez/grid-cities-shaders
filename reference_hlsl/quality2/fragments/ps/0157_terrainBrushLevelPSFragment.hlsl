// Shader fragment  [PS slot 157]  terrainBrushLevelPSFragment

// ---- uniform parameters ----
uniform struct { float4 mParams; } shaderDataTerrainInfo;   // reg-meta 029502950001000000000008

// ---- declarations / helper functions ----
extern uniform sampler textureMap : register(s0);
extern uniform sampler textureMapPreviousRTT : register(s1);

// ---- fragment body (spliced into the generated main()) ----
const float param0 = shaderDataTerrainInfo.mParams.x;
const float param1 = shaderDataTerrainInfo.mParams.y;
const float param2 = shaderDataTerrainInfo.mParams.z;
const float param3 = shaderDataTerrainInfo.mParams.w;
//get uv texture coordinate from interpolators
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
float2 uv1 = float2(In.texcoord<t0>.z, 1.0-In.texcoord<t0>.w); //world space position projected into uv space
//intensity set in swarm
float intensity=param3;
//read texel value
float texelValue = tex2D(textureMap, uv).r;
texelValue*=intensity; //modulate
texelValue*=tex2D(textureMap, uv).a; //alpha channel modulates value
//read texel value from previous RTT (ie the current height map we are creating)
float texelValueRTT = tex2D(textureMapPreviousRTT, uv1).r;
//get the target height value that represents the height we wish to make this pixel
float levelValue=param0;
//get the difference between current texel and the value from swarm.  this is how much we need to add to current value in frame buffer
float diff=levelValue - texelValueRTT;
float finalValue= texelValueRTT + (diff* texelValue);
Current.color = float4(finalValue,finalValue,finalValue,1.0);
