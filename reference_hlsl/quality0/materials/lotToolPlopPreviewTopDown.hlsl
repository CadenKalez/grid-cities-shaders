// Material shader: lotToolPlopPreviewTopDown
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: interpolateWorldPositionVF   (cond 0000000000000000000000000000000000000000000000ff)
    // Vertex positions are already in world-space.
    Current.texcoord<t0> = In.position.xyz;
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
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
uniform struct cLotInstanceInfo { float4 colorsR;float4 colorsG;float4 colorsB;float4 colorNormalsIdx;float4 borderWidthXYZW;float4 borderColorsR;float4 borderColorsG;float4 borderColorsB;float4 borderNormalsIdx;float4 baseTileUVMinMax;float4 overlayTileUVMinMax;float4 colorHeights;float4 borderHeights;} lotInstanceInfo[14];
sampler overlayTextureSampler : register(s0);
sampler lotTextureSampler : register(s1);

void main_pixel()
{
    // --- fragment: overlayBlend4Chan   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: lotToolPlopPreviewSetupPF   (cond 0000000000000000000000000000000000000000000000ff)
    cLotInstanceInfo instanceInfo = lotInstanceInfo[0];
    float tileIndex = instanceInfo.baseTileUVMinMax.x;
    float2 lotBaseUVMin = float2(frac(tileIndex * .25),floor(tileIndex * .25)*0.25);
    float2 lotBaseUVMax = lotBaseUVMin + float2(0.25,0.25);
    float2 uv_ddx = ddx(In.texcoord<t0>.xy*abs(lotBaseUVMin-lotBaseUVMax));
    float2 uv_ddy = ddy(In.texcoord<t0>.xy*abs(lotBaseUVMin-lotBaseUVMax));
    float2 lotTexCoord = lerp(lotBaseUVMin,lotBaseUVMax,In.texcoord<t0>.xy);
    float4 lotTexMask = tex2D(lotTextureSampler, lotTexCoord);
    float2 vertexUV = In.texcoord<t0>.xy;
    lotTexMask.a = 1.0f;
    float2 overlayTexCoord = lerp(instanceInfo.overlayTileUVMinMax.xy, instanceInfo.overlayTileUVMinMax.zw, In.texcoord<t0>.xy);
    float4 overlayTexMask = tex2D(overlayTextureSampler, overlayTexCoord);
    // --- fragment: lotToolPlopPreviewTerrainMask   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPos = In.texcoord<t0>;
    // Additional data setup by lotToolPlopPreviewSetupPF
    float alpha = max(lotTexMask.a, overlayTexMask.a);
    //clip(alpha-(1.0/255.0));
    float adjustedHeight = worldPos.z + 1024.0f - 0.1f;
    adjustedHeight /= 2048.0;
    float resultHeight = saturate(adjustedHeight);
    resultHeight = resultHeight * 255.0;
    Current.color.xyzw = float4(floor(resultHeight) / 255.0, floor(frac(resultHeight)*255.0) / 255.0, alpha, alpha);
}
