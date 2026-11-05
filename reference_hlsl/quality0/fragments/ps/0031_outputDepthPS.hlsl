// Shader fragment  [PS slot 31]  outputDepthPS

// ---- fragment body (spliced into the generated main()) ----
float outputDepth = In.color.x;
Current.color.xyz = float3(floor(outputDepth) / 255.0, floor(frac(outputDepth)*255.0) / 255.0, frac(outputDepth*255.0));
