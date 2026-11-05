// Shader fragment  [PS slot 355]  treeParticleCommonOutputDiffusePS

// ---- fragment body (spliced into the generated main()) ----
Current.color = diffuseMapSample;
Current.color1 = float4(normalDepth.xyz * 0.5f + 0.5f, diffuseMapSample.a);
