// Shader fragment  [PS slot 93]  effectSimpleInputPF

// ---- fragment body (spliced into the generated main()) ----
float4  color           =  In.color;
float2  uvTile1         =  In.texcoord0.xy;
float2  uvTile2         =  In.texcoord0.zw;
float   frameDelta      =  In.texcoord1.x;
float   blackPoint      =  In.texcoord1.z;
float   midPoint        =  In.texcoord1.w;
float4  particleClipPos  =  In.texcoord2;
