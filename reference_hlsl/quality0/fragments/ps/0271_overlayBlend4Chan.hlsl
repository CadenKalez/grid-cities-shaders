// Shader fragment  [PS slot 271]  overlayBlend4Chan

// ---- declarations / helper functions ----
float4 overlayGetAlpha(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, float4 borderWidth)
{
float2 width = fwidth(texCoord);  //abs(ddx(texCoord)) + abs(ddy(texCoord));
float lineEdge = blurWidth*max(width.x,width.y)*1.5;
float4 maskCenters = make_float4(maskCenter) - borderWidth;
//float4 masks = smoothstep(max(maskCenters-lineEdge,0.05f),min(maskCenters+lineEdge,0.95f),pixelRGBA.rgba);
 float4 masks = (pixelRGBA>maskCenters)?1:0;

return make_float4(saturate(dot(masks,float4(1,1,1,1))));
}
float4 overlayGetAlphaAndIndex(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, inout float index,
float4 colorNormals, float4 borderNormals, float4 borderWidth)
{
float2 width = fwidth(texCoord);  //abs(ddx(texCoord)) + abs(ddy(texCoord));
float lineEdge = blurWidth*max(width.x,width.y)*1.5;
float4 maskCenters = maskCenter - borderWidth;
float4 borderCenters = maskCenter + borderWidth;
float4 masks = smoothstep(max(maskCenters-lineEdge,0.05f),min(maskCenters+lineEdge,0.95f),pixelRGBA.rgba);
float4 borderMask = 1.0f-smoothstep(max(borderCenters-lineEdge,0.05f),min(borderCenters+lineEdge,0.95f),pixelRGBA.rgba);
index = masks.x>0.5?(borderMask.x>0.5?borderNormals.x:colorNormals.x):index;
index = masks.y>0.5?(borderMask.y>0.5?borderNormals.y:colorNormals.y):index;
index = masks.z>0.5?(borderMask.z>0.5?borderNormals.z:colorNormals.z):index;
index = masks.w>0.5?(borderMask.w>0.5?borderNormals.w:colorNormals.w):index;
index = floor(index);
return make_float4(saturate(dot(masks,float4(1,1,1,1))));
}
void addOverlay(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, inout float4 lotColor, inout float overlayMask,
float4 colorsR, float4 colorsG, float4 colorsB,
float4 bordersR, float4 bordersG, float4 bordersB, float4 borderWidth)
{
float2 width = fwidth(texCoord);  //abs(ddx(texCoord)) + abs(ddy(texCoord));
float lineEdge = blurWidth*max(width.x,width.y)*1.5;
float4 maskCenters = make_float4(maskCenter) - borderWidth;
float4 borderCenters = maskCenter + borderWidth;
 float4 masks = (pixelRGBA>maskCenters)?1:0;

overlayMask = saturate(dot(masks,float4(1,1,1,1)));
 float4 borderChk = (pixelRGBA>borderCenters)?1:0;

float4 borderMask = min(1.0f-borderChk,masks);
float lastMax = saturate(1-borderMask.w);
masks = min(masks, lastMax);
lastMax = saturate(lastMax-masks.w);
borderMask.xyz = min(borderMask.xyz, lastMax);
lastMax = saturate(lastMax-borderMask.z);
masks.xyz = min(masks.xyz, lastMax);
lastMax = saturate(lastMax-masks.z);
borderMask.xy = min(borderMask.xy, lastMax);
lastMax = saturate(lastMax-borderMask.y);
masks.xy = min(masks.xy, lastMax);
lastMax = saturate(lastMax-masks.y);
borderMask.x = min(borderMask.x, lastMax);
lastMax = saturate(lastMax-borderMask.x);
masks.x = min(masks.x, lastMax);
lotColor.rgb = float3(dot(colorsR,masks)+dot(bordersR,borderMask),dot(colorsG,masks)+dot(bordersG,borderMask),dot(colorsB,masks)+dot(bordersB,borderMask)) + saturate(1-overlayMask)*lotColor.rgb;
lotColor.a = saturate(lotColor.a+overlayMask);
}
void overlayGetHeight(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter, inout float height,
float4 colorWs, float4 borderWs, float4 borderWidth)
{
float2 width = fwidth(texCoord);  //abs(ddx(texCoord)) + abs(ddy(texCoord));
float lineEdge = blurWidth*max(width.x,width.y)*1.5;
float4 maskCenters = make_float4(maskCenter) - borderWidth;
float4 borderCenters = maskCenter + borderWidth;
float4 masks = smoothstep(max(maskCenters-lineEdge,0.05f),min(maskCenters+lineEdge,0.95f),pixelRGBA.rgba);
//float4 masks = make_float4(pixelRGBA.rgba>maskCenters?1:0);
float4 borderMask = 1.0f-smoothstep(max(borderCenters-lineEdge,0.05f),min(borderCenters+lineEdge,0.95f),pixelRGBA.rgba);
float4 heights = lerp(colorWs,borderWs,borderMask);
height = lerp(height,heights.x,masks.x);
height = lerp(height,heights.y,masks.y);
height = lerp(height,heights.z,masks.z);
height = lerp(height,heights.w,masks.w);
}

// ---- fragment body (spliced into the generated main()) ----

