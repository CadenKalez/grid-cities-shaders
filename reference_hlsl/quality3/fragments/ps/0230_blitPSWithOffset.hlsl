// Shader fragment  [PS slot 230]  blitPSWithOffset

// ---- uniform parameters ----
uniform struct { float4 mParams; } shaderDataTerrainInfo;   // reg-meta 029502950001000000000008

// ---- declarations / helper functions ----
sampler srcMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
const float textureWidth = shaderDataTerrainInfo.mParams.x;
const float textureHeight = shaderDataTerrainInfo.mParams.y;
float2 uv = In.texcoord<t0>.xy;
float4 pixel = tex2D(srcMap, uv).rgba;
Current.color = pixel;
