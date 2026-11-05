// Shader fragment  [PS slot 329]  decalSDF

// ---- fragment body (spliced into the generated main()) ----
float4 sdfColor = float4(0, 0, 0, 0);
float glossUnused = 0;
const float kBlurWidth = 1;
const float kMaskCenter = 0.5;
float4 sdfMasks = Current.color;
addOverlay(Current.color, uv, kBlurWidth, kMaskCenter, sdfColor, glossUnused,
decalMaterialData[0], decalMaterialData[1], decalMaterialData[2],
decalMaterialData[0], decalMaterialData[1], decalMaterialData[2], float4(0, 0, 0, 0));
Current.color = sdfColor;
