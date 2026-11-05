// Shader fragment  [PS slot 298]  textureLotBaseTerrainMask

// ---- fragment body (spliced into the generated main()) ----
//clip(lotTexMask.a-(1.0/255.0));
float adjustedHeight = In.texcoord7.z + 1024.0 - 0.1;
adjustedHeight /= 2048.0;
float resultHeight = saturate(adjustedHeight);
resultHeight = resultHeight * 255.0;
Current.color.xyzw = float4(floor(resultHeight) / 255.0, floor(frac(resultHeight)*255.0) / 255.0, 1, floor(lotTexMask.a+1.0/255.0) * floor(In.texcoord2.w + 1.0/255.0));
