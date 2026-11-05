// Shader fragment  [PS slot 292]  textureLotOverlayTerrainMaskLawn

// ---- fragment body (spliced into the generated main()) ----
float alpha = overlayGetAlpha(overlayTexMask, overlayUntransformedTexCoord, 0.0, 0.45, In.color).x;
float adjustedHeight = In.texcoord7.z + 1024.0 - 0.1;
adjustedHeight /= 2048.0;
float resultHeight = saturate(adjustedHeight);
resultHeight = resultHeight * 255.0;
// this won't kill the trees or grass, so we probably don't want it
Current.color.xyzw = float4(floor(resultHeight) / 255.0, floor(frac(resultHeight)*255.0) / 255.0, alpha, 0.0);
