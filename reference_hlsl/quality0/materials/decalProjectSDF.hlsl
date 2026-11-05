// Material shader: decalProjectSDF
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 SkinBones[(192)];
uniform float4x4 worldToClip;
uniform float4x3 cameraToWorld;

void main_vertex()
{
    // --- fragment: depthInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float hw = Current.position.w;
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    int xformIdx = toInt(Current.indices.x);
    float3x4 modelToWorld = float3x4(SkinBones[xformIdx + 0], SkinBones[xformIdx + 1], SkinBones[xformIdx + 2]);
    float3x4 modelToTexture = float3x4(In.texcoord1, In.texcoord2, In.texcoord3);
    float3 modelPos = Current.position.xyz;
    float3 worldPos = mul(modelToWorld, float4(modelPos,1));
    Current.position = mul(float4(worldPos,1), worldToClip);
    Current.texcoord<t0> = In.texcoord0;
    // --- fragment: decalProject   (cond 0000000000000000000000000000000000000000000000ff)
    float3x4 cameraToWorldT = transpose(cameraToWorld);
    float4x4 cameraToWorld44 = float4x4(
    cameraToWorldT[0],
    cameraToWorldT[1],
    cameraToWorldT[2],
    float4(0,0,0,1));
    float invSqrMWScale = 1.0 / dot(modelToWorld[0].xyz, modelToWorld[0].xyz);
    float3x3 modelToWorldT33 = transpose(make_float3x3(modelToWorld)) * invSqrMWScale;
    float3   newTranslation  = -mul(modelToWorldT33, float3(modelToWorld[0].w, modelToWorld[1].w, modelToWorld[2].w));
    float4x4 worldToModel = float4x4(
    float4(modelToWorldT33[0], newTranslation.x),
    float4(modelToWorldT33[1], newTranslation.y),
    float4(modelToWorldT33[2], newTranslation.z),
    float4(0,0,0,1));
    float4x4 cameraToModel = mul(worldToModel, cameraToWorld44);
    float4x4 cameraToTexture = mul(float4x4(modelToTexture[0], modelToTexture[1], modelToTexture[2], float4(0,0,0,1)), cameraToModel);
    Current.texcoord<t0> = cameraToTexture[0];
    Current.texcoord<t1> = cameraToTexture[1];
    Current.texcoord<t2> = cameraToTexture[2];
    // --- fragment: decalMaterialInfo   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = Current.indices.yzw * (1.0 / 255.0);
    // --- fragment: decalMaterialData4SDFSwizzle   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4(In.texcoord4.x,In.texcoord5.x,In.texcoord6.x,In.texcoord7.x);
    Current.color1 = float4(In.texcoord4.y,In.texcoord5.y,In.texcoord6.y,In.texcoord7.y);
    Current.texcoord<t0> = float4(In.texcoord4.z,In.texcoord5.z,In.texcoord6.z,In.texcoord7.z);
    Current.texcoord<t1> = float4(In.texcoord4.w,In.texcoord5.w,In.texcoord6.w,In.texcoord7.w);
}

//==============================================================================
// PIXEL SHADER  (9 fragments; each may be conditionally enabled)
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
uniform float4 renderTargetInfo0;
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
uniform float4 viewFarCorners[4];

void main_pixel()
{
    // --- fragment: overlayBlend4Chan   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: depthInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texXform = In.texcoord<t0>;
    // --- fragment: decalProject   (cond 0000000000000000000000000000000000000000000000ff)
     float screenV = screenUV.y;
    
    float3 farPlaneXYZ =
    lerp(
    lerp(viewFarCorners[1].xyz, viewFarCorners[3].xyz, screenUV.x),
    lerp(viewFarCorners[0].xyz, viewFarCorners[2].xyz, screenUV.x),
    screenV);
    float3 camXYZ = farPlaneXYZ * depth;
    float4x4 camToTexture = float4x4(In.texcoord<t0>, In.texcoord<t1>, In.texcoord<t2>, float4(0,0,0,1));
    float3 texturePosition = mul(camToTexture, float4(camXYZ, 1)).xyz;
    float2 uvOrig = texturePosition.xy * -0.5 + 0.5;
    float2 uv = uvOrig * texXform.xy + texXform.zw;
    float4 decalTexture = tex2D(Sampler<s0>, uv);
    Current.color = decalTexture;
    // --- fragment: decalClip   (cond 0000000000000000000000000000000000000000000000ff)
    clip(1 - abs(texturePosition));
    // --- fragment: decalMaterialData4   (cond 0000000000000000000000000000000000000000000000ff)
    float4 decalMaterialData[4] = { In.color, In.color1, In.texcoord<t0>, In.texcoord<t1> };
    // --- fragment: decalSDF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 sdfColor = float4(0, 0, 0, 0);
    float glossUnused = 0;
    const float kBlurWidth = 1;
    const float kMaskCenter = 0.5;
    float4 sdfMasks = Current.color;
    addOverlay(Current.color, uv, kBlurWidth, kMaskCenter, sdfColor, glossUnused,
    decalMaterialData[0], decalMaterialData[1], decalMaterialData[2],
    decalMaterialData[0], decalMaterialData[1], decalMaterialData[2], float4(0, 0, 0, 0));
    Current.color = sdfColor;
    // --- fragment: decalMaterialInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float4 decalMaterialInfo = In.texcoord<t0>;
    // --- fragment: decalOpacity   (cond 0000000000000000000000000000000000000000000000ff)
    // Relies on float4 decalMaterialInfo
    Current.color.a *= decalMaterialInfo.x;
}
