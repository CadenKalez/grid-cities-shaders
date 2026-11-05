// Shader fragment  [PS slot 358]  treeParticleCommonDeferredPS

// ---- fragment body (spliced into the generated main()) ----
float outputDepth;
outputDepth = In.texcoord<t0>.x;
outputDepth = saturate(outputDepth + normalDepth.w * In.texcoord<t0>.y);
Current.color = float4(floor(outputDepth * 255.0) / 255.0, frac(outputDepth * 255.0), frac(frac(outputDepth * 255.0)*255.0), 8.0/255);
