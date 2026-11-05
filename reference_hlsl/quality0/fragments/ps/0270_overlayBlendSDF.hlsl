// Shader fragment  [PS slot 270]  overlayBlendSDF

// ---- declarations / helper functions ----
float4 overlayGetAlpha(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, float4 borderWidth)
{
float4 width = fwidth(pixelRGBA.rgba);  //abs(ddx(texCoord)) + abs(ddy(texCoord));
float4 lineEdge = blurWidth*width*1.5;
float2 bounds = abs(texCoord-saturate(texCoord));
pixelRGBA.a = (bounds.x>0 || bounds.y>0)?0:pixelRGBA.a;
return smoothstep(max(maskCenter-lineEdge,0.05f),min(maskCenter+lineEdge,0.95f),pixelRGBA.a);
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
float4 width = fwidth(pixelRGBA.rgba);  //abs(ddx(texCoord)) + abs(ddy(texCoord));
float4 lineEdge = blurWidth*width*1.5;
float2 bounds = abs(texCoord-saturate(texCoord));
pixelRGBA.a = (bounds.x>0 || bounds.y>0)?0:pixelRGBA.a;
overlayMask = saturate(smoothstep(max(maskCenter-lineEdge,0.05f),min(maskCenter+lineEdge,0.95f),pixelRGBA.a));
lotColor.rgb = lerp(lotColor.rgb, pixelRGBA.rgb, mask);
lotColor.a = saturate(lotColor.a+mask);
}
void overlayGetHeight(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, inout float height,
float4 colorWs, float4 borderWs, float4 borderWidth)
{
height = 0.0;
}

// ---- fragment body (spliced into the generated main()) ----

