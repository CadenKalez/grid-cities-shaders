// Shader fragment  [PS slot 307]  lotToolPlopPreviewTerrainMask

// ---- fragment body (spliced into the generated main()) ----
float4 worldPos = In.texcoord<t0>;
// Additional data setup by lotToolPlopPreviewSetupPF
float alpha = max(lotTexMask.a, overlayTexMask.a);
//clip(alpha-(1.0/255.0));
float adjustedHeight = worldPos.z + 1024.0f - 0.1f;
adjustedHeight /= 2048.0;
float resultHeight = saturate(adjustedHeight);
resultHeight = resultHeight * 255.0;
Current.color.xyzw = float4(floor(resultHeight) / 255.0, floor(frac(resultHeight)*255.0) / 255.0, alpha, alpha);
