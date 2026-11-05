// Shader fragment  [PS slot 347]  sampleTreeDeferredDepth

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseMap = tex2D(Sampler<s0>, In.texcoord<t0>);
clip(diffuseMap.a - 0.5);
