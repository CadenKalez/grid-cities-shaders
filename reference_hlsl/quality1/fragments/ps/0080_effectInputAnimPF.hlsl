// Shader fragment  [PS slot 80]  effectInputAnimPF

// ---- fragment body (spliced into the generated main()) ----
float4  color           = In.color;
float2  tileUV1         = In.texcoord0.xy;
float2  tileUV2         = In.texcoord0.zw;
float   tileBlend       = In.texcoord1.x;
float2  uv              = In.texcoord1.zw;
