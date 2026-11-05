// Shader fragment  [VS slot 95]  effectNoTransSetupVF

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord0.xy;
float scale = 1; // scale is only on cpu
Current.texcoord<t0>.w = Current.color1.w; // transfer id
