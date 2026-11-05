// Shader fragment  [PS slot 291]  textureLotOverlayTerrainMaskDirt

// ---- fragment body (spliced into the generated main()) ----
float alpha = overlayGetAlpha(overlayTexMask, overlayUntransformedTexCoord, 0.0, 0.45, In.color).x;
float adjustedHeight = In.texcoord7.z + 1024.0 - 0.1;
adjustedHeight /= 2048.0;
float resultHeight = saturate(adjustedHeight);
resultHeight = resultHeight * 255.0;
Current.color.xyzw = float4(floor(resultHeight) / 255.0, floor(frac(resultHeight)*255.0) / 255.0, alpha, 1.0 * floor(In.texcoord2.w + 1.0/255.0));
