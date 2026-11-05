// Shader fragment  [PS slot 345]  alphaTestDiffuseMap

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseMapColor = tex2D(diffuseTextureSampler, In.texcoord0.xy);
clip(diffuseMapColor.a - 0.5);
