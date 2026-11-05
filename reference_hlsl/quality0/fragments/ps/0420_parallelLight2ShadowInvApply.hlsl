// Shader fragment  [PS slot 420]  parallelLight2ShadowInvApply

// ---- fragment body (spliced into the generated main()) ----
color2 *= (1-shadow);
Current.color += color2;
