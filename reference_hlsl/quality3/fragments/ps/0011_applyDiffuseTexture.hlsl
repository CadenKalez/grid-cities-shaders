// Shader fragment  [PS slot 11]  applyDiffuseTexture

// ---- samplers ----
sampler diffuseTextureSampler;

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
Current.color *= diffuseTexture;
