// Shader fragment  [PS slot 81]  effectBlackCrushAnimInputPF

// ---- fragment body (spliced into the generated main()) ----
float4  color           = In.color;
float2  tileUV1         = In.texcoord0.xy;
float2  tileUV2         = In.texcoord0.zw;
float   tileBlend       = In.texcoord1.x;
float   blackPoint		= In.texcoord1.z;
float   midPoint		= In.texcoord1.w;
