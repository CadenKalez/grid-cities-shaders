// Material shader: decalProjectSDFFront
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (6 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 SkinBones[(192)];
uniform float4x4 worldToClip;
uniform float4x3 cameraToWorld;
void BackTransformDirectionsNUS(float3x4 transform, out float3 x, out float3 y, out float3 z)
{
// assumes transform is non-uniform scale + rotation + translation
// i.e. M3x3 = NUS * Rot
//
// key insight here:
//   M3x3_inv
//   {def of M3x3}
//   = (NUS * Rot)_inv
//   {inv/* distribution law}
//   = Rot_inv * NUS_inv
//   {Rot is orthonormal, so inv == transpose}
//   = Rot_T * NUS_inv
//   {I}
//   = Rot_T * I * NUS_inv
//   {m * m_inv == I}
//   = Rot_T * NUS * NUS_inv * NUS_inv
//   {associate}
//   = (Rot_T * NUS) * NUS_inv^2
//   {for all NUS matrices m, m_T == m}
//   = (Rot_T * NUS_T) * NUS_inv^2
//   {transpose/* distribution law}
//   = (NUS * Rot)_T * NUS_inv^2
//   {def of M3x3}
//   = M3x3_T * NUS_inv^2
//
// Can extract NUS from M since Rot is orthonormal using dot of columns
float3 sqrScale;
sqrScale.x = dot(transform[0].xyz, transform[0].xyz);
sqrScale.y = dot(transform[1].xyz, transform[1].xyz);
sqrScale.z = dot(transform[2].xyz, transform[2].xyz);
float3 invSqrScale = 1.0 / sqrScale;
// apply M3x3_T * NUS_inv^2 to x=(1,0,0), y=(0,1,0), z=(0,0,1)
x = (transform[0] * invSqrScale.x).xyz;
y = (transform[1] * invSqrScale.y).xyz;
z = (transform[2] * invSqrScale.z).xyz;
}

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
    // --- fragment: decalWorldDirection   (cond 0000000000000000000000000000000000000000000000ff)
    // urk can't backtransform modeltotexture because nonuniform scale assumption is violated
    float3 x, y, z;
    BackTransformDirectionsNUS(modelToTexture, x, y, z);
    float3 worldTextureDirection = mul(modelToWorld, float4(-z, 0));
    // these calculations will get skipped if not needed
    float3 worldTextureU = mul(modelToWorld, float4(-x, 0));
    float3 worldTextureV = mul(modelToWorld, float4(-y, 0));
    Current.texcoord<t0>.xyz = worldTextureDirection;
    // --- fragment: decalMaterialData4SDFSwizzle   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4(In.texcoord4.x,In.texcoord5.x,In.texcoord6.x,In.texcoord7.x);
    Current.color1 = float4(In.texcoord4.y,In.texcoord5.y,In.texcoord6.y,In.texcoord7.y);
    Current.texcoord<t0> = float4(In.texcoord4.z,In.texcoord5.z,In.texcoord6.z,In.texcoord7.z);
    Current.texcoord<t1> = float4(In.texcoord4.w,In.texcoord5.w,In.texcoord6.w,In.texcoord7.w);
    // --- fragment: decalMaterialInfo   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = Current.indices.yzw * (1.0 / 255.0);
}

//==============================================================================
// PIXEL SHADER  (12 fragments; each may be conditionally enabled)
//==============================================================================
uniform sampler2D deferredLightingSampler       : register(s12);
uniform sampler2D deferredNormalSampler         : register(s14);
float4 GetDeferredLight( float2 screenUV )
{
return tex2D( deferredLightingSampler, screenUV );
}
float3 GetDeferredNormal( float2 screenUV )
{
float4 sample = tex2D( deferredNormalSampler, screenUV );
sample.xyz = normalize(sample.xyz * 2.0 - 1.0);
return sample.xyz;
}
float4 GetDeferredNormalAndSpec( float2 screenUV )
{
float4 sample = tex2D( deferredNormalSampler, screenUV );
sample.xyz = normalize(sample.xyz * 2.0 - 1.0);
return sample;
}
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
    // --- fragment: deferredDiffuseEnabled   (cond 0000000000000000000000000000000000000000000000ff)
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
    // --- fragment: decalWorldDirection   (cond 0000000000000000000000000000000000000000000000ff)
    float3 decalWorldDirection = In.texcoord<t0>.xyz;
    // --- fragment: decalClip   (cond 0000000000000000000000000000000000000000000000ff)
    clip(1 - abs(texturePosition));
    // --- fragment: decalClipBack   (cond 0000000000000000000000000000000000000000000000ff)
    {
    float3 worldNormal = GetDeferredNormal(screenUV);
    clip(dot(decalWorldDirection, worldNormal));
    }
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
