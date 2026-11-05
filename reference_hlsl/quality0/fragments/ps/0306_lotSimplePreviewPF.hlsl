// Shader fragment  [PS slot 306]  lotSimplePreviewPF

// ---- fragment body (spliced into the generated main()) ----
// Additional data setup by lotToolPlopPreviewSetupPF
float overlayMask = 0.0;
float gloss = 0.0f;
addOverlay(overlayTexMask, vertexUV, 1.0, 0.5f, lotTexMask, overlayMask,
instanceInfo.colorsR, instanceInfo.colorsG, instanceInfo.colorsB,
instanceInfo.borderColorsR, instanceInfo.borderColorsG, instanceInfo.borderColorsB,
instanceInfo.borderWidthXYZW);
Current.color.rgb = lotTexMask.rgb * In.color.a;
Current.color.a = lotTexMask.a * In.color.a;
