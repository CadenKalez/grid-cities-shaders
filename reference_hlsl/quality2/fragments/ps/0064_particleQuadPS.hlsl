// Shader fragment  [PS slot 64]  particleQuadPS

// ---- samplers ----
sampler diffuse;

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(diffuse, Current.texcoord0);
Current.color = Current.color * texColor;
