// Shader fragment  [PS slot 78]  effectBlackCrushPickInputPF

// ---- fragment body (spliced into the generated main()) ----
float4  color           = In.color;
float2  tileUV          = In.texcoord0.xy;
float   blackPoint		= In.texcoord0.z;
float   midPoint		= In.texcoord0.w;
