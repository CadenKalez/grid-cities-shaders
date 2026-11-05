// Shader fragment  [PS slot 357]  treeParticleCommonDeferredClipPS

// ---- fragment body (spliced into the generated main()) ----
clip((diffuseMapSample.a * alphaFade) - 1.0);
