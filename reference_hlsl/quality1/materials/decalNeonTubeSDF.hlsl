// Material shader: decalNeonTubeSDF
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 SkinBones[(192)];
uniform float4x4 worldToClip;
uniform float4 customParams[16];
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
    // --- fragment: decalBaseCenter   (cond 0000000000000000000000000000000000000000000000ff)
    int xformIdx = toInt(Current.indices.x);
    float3x4 modelToWorld = float3x4(SkinBones[xformIdx + 0], SkinBones[xformIdx + 1], SkinBones[xformIdx + 2]);
    float3x4 modelToTexture = float3x4(In.texcoord1, In.texcoord2, In.texcoord3);
    float3 modelPos = Current.position.xyz;
    float3 texturePosition = mul(modelToTexture, float4(modelPos,1));
    float sqrScale = dot(modelToTexture[2].xyz, modelToTexture[2].xyz);
    float invSqrScale = 1.0 / sqrScale;
    modelPos += (modelToTexture[2].xyz * invSqrScale) * -texturePosition.z;
    float3 worldPosition = mul(modelToWorld, float4(modelPos,1));
    Current.position = mul(float4(worldPosition,1), worldToClip);
    Current.texcoord<t0> = In.texcoord0;
    // --- fragment: decalMaterialInfoWithObjectData   (cond 0000000000000000000000000000000000000000000000ff)
    int realXformIdx = xformIdx / 3; // Why did I premultiply these again?  So silly.
    int customParamIndex = realXformIdx / 4;
    int customParamCpt = realXformIdx % 4;
    Current.texcoord<t0>.xyz = Current.indices.yzw * (1.0 / 255.0);
    Current.texcoord<t0>.w = customParams[customParamIndex][customParamCpt];
    // --- fragment: decalFloatQuad   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = mul(modelToTexture, float4(modelPos,1));
    // --- fragment: decalMaterialData4SDFSwizzle   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4(In.texcoord4.x,In.texcoord5.x,In.texcoord6.x,In.texcoord7.x);
    Current.color1 = float4(In.texcoord4.y,In.texcoord5.y,In.texcoord6.y,In.texcoord7.y);
    Current.texcoord<t0> = float4(In.texcoord4.z,In.texcoord5.z,In.texcoord6.z,In.texcoord7.z);
    Current.texcoord<t1> = float4(In.texcoord4.w,In.texcoord5.w,In.texcoord6.w,In.texcoord7.w);
    // --- fragment: decalWorldDirection   (cond 0000000000000000000000000000000000000000000000ff)
    // urk can't backtransform modeltotexture because nonuniform scale assumption is violated
    float3 x, y, z;
    BackTransformDirectionsNUS(modelToTexture, x, y, z);
    float3 worldTextureDirection = mul(modelToWorld, float4(-z, 0));
    // these calculations will get skipped if not needed
    float3 worldTextureU = mul(modelToWorld, float4(-x, 0));
    float3 worldTextureV = mul(modelToWorld, float4(-y, 0));
    Current.texcoord<t0>.xyz = worldTextureDirection;
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
float4 masks = smoothstep(max(maskCenters-lineEdge,0.05f),min(maskCenters+lineEdge,0.95f),pixelRGBA.rgba);
overlayMask = saturate(dot(masks,float4(1,1,1,1)));
float4 borderMask = min(1.0f-smoothstep(max(borderCenters-lineEdge,0.05f),min(borderCenters+lineEdge,0.95f),pixelRGBA.rgba),masks);
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
uniform float4 gameInfo;
const static float kSH_A1 = 2.0 / 3.0;
const static float kSH_A2 = 1.0 / 4.0;
const static float kSH_A3 = 0;
const static float kSH_A4 = -1.0 / 24.0;
const static float kDefaultGloss = 0.00;
const static float kGlossyMax    = 1.0; // threshold at which glossy maxes out
const static float kCelOutlineThreshold        = 0.25;
const static float kCelOutlineThresholdRange   = 0.075;
const static float kCelStrength                = 0.3;
const static float kSpecExponentMaxValue = 60.0;
const static bool kSaveInstructions = false;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;
uniform float4 worldCameraDirection;
uniform float4 screenInfo;
static const bool  kAvoidDesaturation   = true;
static const bool  kUseSkyTable         = true;
static const float3 kXYZToR = float3( 2.80298,   -1.18735,  -0.437286);
static const float3 kXYZToG = float3(-1.07909,    1.97927,   0.0423073);
static const float3 kXYZToB = float3( 0.0746015, -0.248513,  1.08196);
float3 xyYToXYZ(float3 c)
{
return float3(c.x, c.y, 1.0 - c.x - c.y) * c.z / c.y;
}
float Perez
(
float4 lambdas,
float  cosTheta,
float  gammaS,
float  cosGamma
)
{
return (1.0 + lambdas.x * exp(lambdas.y / cosTheta))
* (1.0 + lambdas.z * exp(gammaS) + lambdas.w * cosGamma * cosGamma);
}
float3 SkyColorTG(cSunSkyInfo info, float cosTheta, float cosGamma, float gamma)
{
float3 xyY;
float3 a = info.mPerezA.xyz;
float3 b = info.mPerezB.xyz;
float3 c = info.mPerezC.xyz;
float3 d = info.mPerezD.xyz;
float3 e = info.mPerezE.xyz;
float3 ecb = exp(b / cosTheta);
float3 egd = exp(gamma * d);
float cg2 = cosGamma * cosGamma;
xyY = (1 + a * ecb) * (1 + c * egd + e * cg2);
float3 skyBase = info.mInvDensity.xyz;
xyY *= skyBase;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y;
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressedWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTable(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressed(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
sampler skyTermTableXXX : register(s11);
float3 SkyColor(cSunSkyInfo info, float3 v)
{
if (kUseSkyTable)
return SkyColorTableCompressedWithTuning(skyTermTableXXX, info, saturate(v.z), dot(info.mSunDir.xyz, v), 0);
else
{
float cosTheta = saturate(v.z + 1e-6);
float cosGamma = dot(info.mSunDir.xyz, v);
float gamma = acos(cosGamma);
return SkyColorTG(info, cosTheta, cosGamma, gamma);
}
}
float3 SkyColorConv(cSunSkyInfo info, float3 v, float s)
{
float cosTheta = v.z;
float cosGamma = dot(info.mSunDir.xyz, v);
return SkyColorTableCompressed(skyTermTableXXX, info, cosTheta, cosGamma, s);
}
void EnvLighting(float3 normal, float3 viewVector, float s, out float3 shColorDiff, out float3 shColorSpec)
{
s *= 0.75;
float3 reflDir = reflect(viewVector, normal);
float3 sampleDir = normal * (1 - s) + reflDir * s;
shColorDiff = SkyColorConv(sunSky, sampleDir, 1 - s);
shColorSpec = shColorDiff;
shColorDiff *= 1-s;
shColorSpec *= s;
}
float CalcPhongSpec( float3 lightDir, float3 reflectedNormal, float specE )
{
float nDotR = saturate(dot(reflectedNormal, lightDir));
specE = max(specE, 0.001f);
float spec1 = pow(nDotR, specE);
return spec1;
}
float CalcBlinnPhongSpec( float3 lightDir, float3 viewDir, float3 normal, float specE )
{
float3 halfVector = normalize(lightDir - viewDir);
float nDotH = saturate(dot(normal, halfVector));
specE = max(specE, 0.001f);
float spec = pow(nDotH, specE);
return spec;
}
float CalcBlinnPhongSchlick(float3 lightDir, float3 viewDir, float3 normal, float specE, float specF)
{
float3 halfVector = normalize(lightDir - viewDir);
float nDotH = saturate(dot(normal, halfVector));
specE = max(specE, 0.001f);
float spec = pow(nDotH, specE);
float specNormalizingFactor = (specE + 2) / 8;
float schlick = specF + (1.0f - specF) * exp2(-8.656170 * saturate(dot(lightDir, halfVector))); // 8.656170 == 1/ln(2) * 6
//float schlick = specF + (1 - specF)*pow((1 - dot(halfVector,lightDir)),5);
return spec*specNormalizingFactor*schlick;
}
extern uniform sampler lightScalarSampler : register(s13);
void SceneLighting
(
float2 screenUV,
float3 normal,
float3 viewVector,
float  glossyStrength,
float  reflectance,
float  specE,
float  specStrength,
inout float3 shColorDiff,
inout float3 shColorSpec,
inout float3 specHighlight,
out   float  shadow
)
{
float4 lightScalar = tex2D(lightScalarSampler,screenUV);
float directShadow  = lightScalar.x;
float ambientShadow = lightScalar.y;
shadow = directShadow;
EnvLighting(normal, viewVector, glossyStrength, shColorDiff, shColorSpec);
shColorDiff *= ambientShadow;
shColorSpec *= ambientShadow;
float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
float spec = CalcBlinnPhongSchlick( sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance );
specHighlight = spec * specStrength * sunMod * sunSky.mSunColor.rgb * directShadow;
sunMod = pow(max(sunMod,0.0001),1.0+glossyStrength);
//sunMod = exp(sunMod*log(1+glossyStrength));
shColorDiff += sunMod * sunSky.mSunColor.rgb * directShadow;
float4 deferredLight = GetDeferredLight( screenUV );
shColorDiff += deferredLight.rgb;
shColorSpec += deferredLight.a;
}
void SceneLighting
(
float2 screenUV,
float3 normal,
float3 viewVector,
float  glossyStrength,
float  reflectance,
float  specE,
float  specStrength,
inout float3 shColorDiff,
inout float3 shColorSpec,
inout float3 specHighlight
)
{
float shadow = 1.0f;
SceneLighting(
screenUV, normal, viewVector,
glossyStrength, reflectance, specE, specStrength,
shColorDiff, shColorSpec, specHighlight, shadow );
}

void main_pixel()
{
    // --- fragment: deferredDiffuseEnabled   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: overlayBlend4Chan   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texXform = In.texcoord<t0>;
    // --- fragment: decalMaterialInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float4 decalMaterialInfo = In.texcoord<t0>;
    // --- fragment: decalFloatQuadNoClip   (cond 0000000000000000000000000000000000000000000000ff)
    float3 textureFloatPosition = In.texcoord<t0>.xyz;
    float2 uvOrig = textureFloatPosition.xy * -0.5 + 0.5;
    float2 uv = uvOrig * texXform.xy + texXform.zw;
    float4 decalTexture = tex2D(Sampler<s0>, uv);
    Current.color = decalTexture;
    //Current.color.a = 1;
    // --- fragment: decalMaterialData4   (cond 0000000000000000000000000000000000000000000000ff)
    float4 decalMaterialData[4] = { In.color, In.color1, In.texcoord<t0>, In.texcoord<t1> };
    // --- fragment: decalWorldDirection   (cond 0000000000000000000000000000000000000000000000ff)
    float3 decalWorldDirection = In.texcoord<t0>.xyz;
    // --- fragment: decalAnimateSDF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 animResults;
    float4 useV;
    {
    float4 animParameters = decalMaterialData[3];
    useV = float4(animParameters.x > 0 ? 0 : 1, animParameters.y > 0 ? 0 : 1, animParameters.z > 0 ? 0 : 1, animParameters.w > 0 ? 0 : 1);
    animParameters = abs(animParameters);
    animParameters += 0.0001; 
    float animSpeed = decalMaterialInfo.y;
    float animTime = frac(gameInfo.x * animSpeed + 0.9999);  
    float4 animOffsets = frac(animParameters);
    float4 animChunks = max(float4(1.0, 1.0, 1.0, 1.0), floor(animParameters));
    float4 compares = floor((animTime * 3 - animOffsets) * animChunks) * (1 / animChunks);
    float4 uvCompare = lerp(uvOrig.xxxx, uvOrig.yyyy, useV.xyzw);
    animResults = uvCompare - compares;
    }
    // --- fragment: decalAnimateSDFDarken   (cond 0000000000000000000000000000000000000000000000ff)
    float materialTubeLightFactor = decalMaterialInfo.z * 8 + 1;
    float4 lightFactor = lesser_than(animResults, 0) ? float4(materialTubeLightFactor, materialTubeLightFactor, materialTubeLightFactor, materialTubeLightFactor) : float4(0.1, 0.1, 0.1, 0.1);
    float4 powerFactor = lerp(float4(0.5, 0.5, 0.5, 0.5), lightFactor, decalMaterialInfo.wwww);
    decalMaterialData[0] *= powerFactor;
    decalMaterialData[1] *= powerFactor;
    decalMaterialData[2] *= powerFactor;
    /*
    decalMaterialData[0].rgb *= powerFactor.x;
    decalMaterialData[1].rgb *= powerFactor.y;
    decalMaterialData[2].rgb *= powerFactor.z;
    decalMaterialData[3].rgb *= powerFactor.w;
    */
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
    // --- fragment: setupSHBasic   (cond 0000000000000000000000000000000000000000000000ff)
    float specStrength = 0;
    float specE = 1;
    float bumpFactor = 1;
    float gloss = kDefaultGloss;
    // --- fragment: decalLightNeonTube   (cond 0000000000000000000000000000000000000000000000ff)
    float2 shScreenUV = (In.vpos.xy + float2(0.5, 0.5)) * screenInfo.zw;
    float3 bumpNormal = normalize(decalWorldDirection);
    float3 shColorDiff = float3(0, 0, 0);
    float3 shColorSpec = float3(0, 0, 0);
    float3 spec = float3(0, 0, 0);
    SceneLighting(shScreenUV, bumpNormal, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
    Current.color.rgb += shColorSpec + spec;
}
