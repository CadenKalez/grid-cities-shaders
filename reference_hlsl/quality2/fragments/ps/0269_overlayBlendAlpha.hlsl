// Shader fragment  [PS slot 269]  overlayBlendAlpha

// ---- declarations / helper functions ----
float overlayGetAlpha(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, float4 borderWidth)
{
return pixelRGBA.a;
}
float4 overlayGetAlphaAndIndex(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, inout float index,
float4 colorNormals, float4 borderNormals, float4 borderWidth)
{
return float4(overlayGetAlpha(pixelRGBA,texCoord,blurWidth,maskCenter,borderWidth));
}
void addOverlay(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, inout float4 lotColor, inout float overlayMask,
float4 colorsR, float4 colorsG, float4 colorsB,
float4 bordersR, float4 bordersG, float4 bordersB, float4 borderWidth)
{
lotColor.rgb = lerp(lotColor.rgb, pixelRGBA.rgb, pixelRGBA.a);
overlayMask = saturate(pixelRGBA.a);
lotColor.a = saturate(lotColor.a+pixelRGBA.a);
}
void overlayGetHeight(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, inout float height,
float4 colorWs, float4 borderWs, float4 borderWidth)
{
height = 0.0;
}

// ---- fragment body (spliced into the generated main()) ----

