// Shader fragment  [PS slot 150]  genericFadePreMultAlphaPS

// ---- fragment body (spliced into the generated main()) ----
Current.color = float4(Current.color.rgb * 0.7f, Current.color.a * 0.7f);
