// Shader fragment  [PS slot 149]  copyVertexColorPreMultAlphaPS

// ---- fragment body (spliced into the generated main()) ----
Current.color = float4(In.color.rgb * In.color.a, In.color.a);
