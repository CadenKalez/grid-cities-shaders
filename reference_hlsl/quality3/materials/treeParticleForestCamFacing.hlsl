// Material shader: treeParticleForestCamFacing
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 modelToWorld;
uniform struct { float4 mWaterLevel; float4 mTransform; float4 mMapping; } terrainForestInfoVS;
static const float kTreeDirtPatchScale  = 3.0f;
static const float kTreeShadowDarkening = 0.9f;
static const float kStartFadeDistance = 3000.0f;
static const float kEndFadeDistance   = 3750.0f;
static const float kNormalBias = 0.45f;
static const float kCliffCullingAngle = 0.5f;
static const float kTreeMinSize  = 0.3f;
static const float kTreeMaxSize  = 0.9f;
static const float kTreeSizeVary = 0.05f;
static const float kBeachTreeLine = 8.5f;
float GetFadeValue( in float3 worldPos, in float3 worldCameraPos )
{
float distanceToCam = length( worldPos - worldCameraPos );
float fadeValue     = saturate( ( distanceToCam - kStartFadeDistance ) / ( kEndFadeDistance - kStartFadeDistance ) );
return fadeValue;
}
float GetCameraDirFade( in float3 worldCameraDir )
{
const float3 upAxis = float3( 0.0f, 0.0f, 1.0f );
float fadeValue = saturate( dot( -worldCameraDir.xyz, upAxis ) );
return fadeValue;
}
sampler HeightMapVS : register(s0);
sampler EcoMapVS    : register(s1);
sampler NormalMapVS : register(s2);
uniform struct { float4 texXform; float4 cardData; float4 cardDepth; } impostorParticles[64];
uniform float4 gameInfo;
uniform float4x4 cameraToClip;
uniform float4x3 worldToCamera;
uniform float4x3 modelToWorld;
uniform float4 worldCameraPosition;
uniform float4 worldCameraDirection;
static const bool kFixParallax = (1) != 0;
static const float kZBiasFactor = -0.00001;
static const float2 vtxInfo[4] = {
float2(0,0),
float2(0,1),
float2(1,1),
float2(1,0)
};
float3 CalculateTreeWindAnimation(float2 animInfo)
{
float kWaveLength = 10;
float kWaveZero = 5;
float kAnimSpeed = 1;
float kMaxAmplitude = 8;
float wavePos = gameInfo.x + animInfo.x * 0.005;
float animTime = frac(wavePos * (1.0 / (kWaveLength + kWaveZero)));
float animScale = saturate(1 - animTime * ((kWaveLength + kWaveZero) / kWaveLength)) * kMaxAmplitude;
animTime *= (kWaveLength + kWaveZero) * kAnimSpeed;
float waveAmount = sin(sqrt(animTime)) * animScale * animInfo.y;
return mul(float3(-1,0,0), make_float3x3(worldToCamera)) * waveAmount;
}
float4 CalculateFinalPosition(float3 worldPos, float3 camOffset, float4 cardDepth)
{
float3 cPos = mul(float4(worldPos, 1), worldToCamera) + camOffset;
float4 pPos = mul(float4(cPos, 1), cameraToClip);
if ( kFixParallax )
{
float4 offsetW = mul(float4(0,0,1,0), cameraToClip);
pPos.xy -= pPos.w * offsetW.xy;
pPos.xy *= pPos.w / (pPos.w - camOffset.z * offsetW.w);
pPos.xy += pPos.w * offsetW.xy;
}
pPos.z += cardDepth.y * pPos.w * kZBiasFactor;
return pPos;
}

void main_vertex()
{
    // --- fragment: treeParticleForestPosScale   (cond 0000000000000000000000000000000000000000000000ff)
    float2 cornerData = In.texcoord0.xy;
    float3 modelData = In.normal.xyz;
    float3 position = modelPosition.xyz;
    float sampleIndex = In.color.a;
    // The incoming quad positions are in the 0.0f -> 1.0f range.
    float2 mapUV = position.xy * terrainForestInfoVS.mMapping.xy + terrainForestInfoVS.mMapping.zw;
    // Sample height map and then remap 0.0f -> 1.0f value into the
    // -1024.0f -> 1024.0f range.
    float height;
    height = tex2Dlod( HeightMapVS, float4( mapUV, 0.0f, 0.0f ) ).x;
    height *= 2048.0f;
    height -= 1024.0f;
    // Sample the forest eco map and calc the size for the density culling check.
    float density = tex2Dlod( EcoMapVS, float4( mapUV, 0.0f, 0.0f ) ).y;
    float size    = density - sampleIndex;
    // Sample the normal map and then calculate the angle for the cliff culling
    // check.
    float3 normal;
    normal = tex2Dlod( NormalMapVS, float4( mapUV, 0.0f, 0.0f ) ).xyz;
    normal = normal * 2.0f - 1.0f;
    float3 flattenedNormal = normalize( float3( normal.xy, 0.0f ) );
    float  angle           = abs( dot( normal, flattenedNormal ) );
    // Calculate sea level for sea level check. A combination of a shader constant
    // offsetted by the beach level.
    float seaLevel = terrainForestInfoVS.mWaterLevel.x + kBeachTreeLine;
    // The result of drawQuad determines if this tree quad is visible or not. If the
    // result is 1, it means it is visible. 0 means hide the quad. Currently there are
    // 3 checks that determine if the quad is hidden:
    //  1) If it fails the density map check.
    //  2) It is below sea level (plus beach line).
    //  3) if it fails the cliff culling check.
    // TODO: Possbly consider using a dynamic branch to skip the rest of the shader
    //       if it's hidden to save some cost. But would it actually save anything?!
    //       I say that as I can't really find solid info on whether they hurt perf
    //       or not.
    float drawQuad;
    drawQuad = ( size <= 0.0f ) ? 0.0f : 1.0f;
    drawQuad = ( angle >= kCliffCullingAngle ) ? 0.0f : drawQuad;
    drawQuad = ( height < seaLevel ) ? 0.0f : drawQuad;
    position.xy -= terrainForestInfoVS.mTransform.xy;
    position = mul( float4( position, 1.0f ), modelToWorld );
    position.z = height;
    // Calculate the scale. modelData.x holds the random value for size variation.
    float random = frac( modelData.x );
    float scale  = lerp( kTreeMinSize, kTreeMaxSize, size ) + random * kTreeSizeVary;
    // --- fragment: treeParticleForestTransformVS   (cond 0000000000000000000000000000000000000000000000ff)
    // Get information for this corner of the quad
    float2 origQuadCorner = vtxInfo[int(cornerData.x)] * drawQuad; 
    float2 quadCorner = origQuadCorner;
    float3 camMovement = float3(0, 0, 0);
    if(false)  
    {
    camMovement = CalculateTreeWindAnimation(float2(position.x, quadCorner.y));
    }
    // Get direction for offset into texture xform
    float direction = modelData.z;
    // Get model index and per-model data
    int modelIdx = int(modelData.y);
    float4 texXform = impostorParticles[modelIdx].texXform;
    float4 cardData = impostorParticles[modelIdx].cardData;
    float4 cardDepth = impostorParticles[modelIdx].cardDepth;
    // Shrink the card height based upon distance from camera.
    float fadeValue = 1.0f - GetFadeValue( position, worldCameraPosition.xyz );
    quadCorner.y *= saturate( GetCameraDirFade( worldCameraDirection.xyz ) + fadeValue );
    // Offset in camera space
    float3 camOffset = float3(cardData.xy + cardData.zw * quadCorner, cardDepth.x) * scale;
    // Get clip space position of quad corner
    float4 pPos = CalculateFinalPosition(position, camOffset, cardDepth);
    // Offset into atlas by facing
    texXform.x += direction * texXform.z;
    // Get UV
    float2 uv = texXform.xy + texXform.zw * origQuadCorner;
    Current.position = pPos;
    Current.texcoord<t0> = float4(uv, modelData.x, 0.0f);
    Current.texcoord<t1> = float4(position,1);
     Current.texcoord<t0>.y = 1 - Current.texcoord<t0>.y; 
    // Color copied automatically
}

//==============================================================================
// PIXEL SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
float4 GetDeferredLight( float2 screenUV )
{
return float4(0,0,0,0);
}
float3 GetDeferredNormal( float2 screenUV )
{
return float3(0,0,1);
}
float4 GetDeferredNormalAndSpec( float2 screenUV )
{
return float4(0,0,1,1);
}
uniform float4 screenInfo;
uniform float4 samplerInfo0;
uniform float4 worldCameraDirection;
static const float kMipLevelClamp = 5.0f;
sampler offscreenNormalTex : register(s1);
sampler sourceTex          : register(s0);
float CalcMipLevel( float2 uv )
{
float2 dx = ddx( uv );
float2 dy = ddy( uv );
float d = max( dot( dx, dx ), dot( dy, dy ) );
return 0.5f * log2( d );
}
static const bool kPerPixelDepth = true;
float4 ImpostorUnpackNormalDepth(float4 normalMapSample)
{
float2 normalXY = normalMapSample.xy * 2 - 1;
float  xyLen = dot(normalXY, normalXY);
float  depthZSign = normalMapSample.z - 0.5;
float  pixDepth = abs(depthZSign * 2);
float  zSign = (depthZSign >= 0) ? 1 : -1;
float  normalZ = zSign * sqrt(1 - xyLen);
return float4(normalXY, normalZ, pixDepth);
}
float3 ImpostorPackNormalDepth(float3 normal, float pixelDepth)
{
normal = normalize(normal);
float zSign = (normal.z >= 0) ? 0.5 : -0.5;
return float3(normal.xy * 0.5 + 0.5, zSign*pixelDepth + 0.5);
}
uniform struct { float4 mHsvMin; float4 mHsvDiff; } terrainForestInfoPS[4];
float3 CalculateHSVTweakedColor(float3 hsvParamModifiers, float3 diffuseColor)
{
static const float3 kHSVRangeMin = float3(-1 * 3.141592, 0, 0);
static const float3 kHSVRangeMax = float3(1 * 3.141592, 5, 2);
static const float3 kHSVRangeScale = kHSVRangeMax - kHSVRangeMin;
static const float3x3 yiqMat = float3x3(0.299, 0.587, 0.114, 0.596, -0.274, -0.321, 0.211, -0.523, 0.311);
static const float3x3 rgbMat = float3x3(1, 0.956, 0.621, 1, -0.272, -0.647, 1, -1.107, 1.705);
float3 hsvParams = hsvParamModifiers * kHSVRangeScale + kHSVRangeMin;
float kHueRot = hsvParams.r;
float kSatScale = hsvParams.g;
float kValScale = hsvParams.b;
float kHueS, kHueC;
sincos(kHueRot, kHueS, kHueC);
float3 yiqColor = mul(yiqMat, diffuseColor);
yiqColor *= kValScale;
yiqColor.yz *= kSatScale;
yiqColor.yz = mul(float2x2(kHueC, -kHueS, kHueS, kHueC), yiqColor.yz);
return mul(rgbMat, yiqColor);
}
uniform float4 worldCameraDirection;
uniform float4 worldCameraPosition;
static const float kTreeDirtPatchScale  = 3.0f;
static const float kTreeShadowDarkening = 0.9f;
static const float kStartFadeDistance = 3000.0f;
static const float kEndFadeDistance   = 3750.0f;
static const float kNormalBias = 0.45f;
static const float kCliffCullingAngle = 0.5f;
static const float kTreeMinSize  = 0.3f;
static const float kTreeMaxSize  = 0.9f;
static const float kTreeSizeVary = 0.05f;
static const float kBeachTreeLine = 8.5f;
float GetFadeValue( in float3 worldPos, in float3 worldCameraPos )
{
float distanceToCam = length( worldPos - worldCameraPos );
float fadeValue     = saturate( ( distanceToCam - kStartFadeDistance ) / ( kEndFadeDistance - kStartFadeDistance ) );
return fadeValue;
}
float GetCameraDirFade( in float3 worldCameraDir )
{
const float3 upAxis = float3( 0.0f, 0.0f, 1.0f );
float fadeValue = saturate( dot( -worldCameraDir.xyz, upAxis ) );
return fadeValue;
}
uniform float4 worldCameraDirection;
uniform float4 worldCameraPosition;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;
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
// Assuming n will be used to look up a pre-integrated
// lighting function over the sphere, this modifies it to
// approximate the occlusion from a local ground plane given by ng.
float3 ClipToHemisphere(float3 n, float3 ng)
{
float c = dot(n, ng);
return (n + ng) * sqrt(1 + c) / sqrt(8.0);
}
void SceneLightingGround
(
float3 groundNormal,
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
float3 bentNormal = ClipToHemisphere(normal, groundNormal);
float4 lightScalar = tex2D(lightScalarSampler, screenUV);
float directShadow  = lightScalar.x;
float ambientShadow = lightScalar.y;
EnvLighting(bentNormal, viewVector, glossyStrength, shColorDiff, shColorSpec);
shColorDiff *= ambientShadow;
shColorSpec *= ambientShadow;
float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
sunMod *= step(0, dot(sunSky.mSunDir.xyz, groundNormal));
sunMod *= step(0, dot(normal, groundNormal));
sunMod *= step(0, normal.z);
shColorDiff += sunMod * sunSky.mSunColor.rgb * directShadow;
float spec = CalcBlinnPhongSchlick( sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance );
specHighlight = spec * specStrength * sunMod * sunSky.mSunColor.rgb * directShadow;
float4 deferredLight = GetDeferredLight( screenUV );
shColorDiff += deferredLight.rgb;
shColorSpec += deferredLight.a;
}

void main_pixel()
{
    // --- fragment: deferredDiffuseDisabled   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: treeParticleCommonSamplePS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
    float2 uv       = In.texcoord<t0>.xy;
    float  type     = In.texcoord<t0>.z;
    float  mipLevel = 0.0f;
    float4 normalDepth = float4(0.0f, 0.0f, 0.0f, 0.0f);
    mipLevel = CalcMipLevel(uv * samplerInfo0.xy);
    mipLevel = min(mipLevel, kMipLevelClamp);
    float4 diffuseMapSample = tex2Dlod(sourceTex, float4(uv, 0, mipLevel));
    diffuseMapSample.a = saturate(diffuseMapSample.a * (1.0 / 0.9));
    diffuseMapSample.rgb /= diffuseMapSample.a;
    float4 normalMapSample = tex2Dlod(offscreenNormalTex, float4(uv, 0, mipLevel));
    normalMapSample.z /= normalMapSample.a;
    normalDepth = ImpostorUnpackNormalDepth(normalMapSample);
    // --- fragment: treeParticleForestHSVTweakPS   (cond 0000000000000000000000000000000000000000000000ff)
    int treeType = int( floor( type ) );
    float3 treeParams = terrainForestInfoPS[ treeType ].mHsvMin.xyz + terrainForestInfoPS[ treeType ].mHsvDiff.xyz * In.color.rgb;
    diffuseMapSample.rgb = CalculateHSVTweakedColor(treeParams, diffuseMapSample.rgb);
    // --- fragment: treeParticleForestAlphaFadePS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 position = In.texcoord<t0>.xyz;
    float distanceFade = 1.0 - GetFadeValue(position, worldCameraPosition.xyz);
    float alphaFade    = saturate((1.0 - GetCameraDirFade(worldCameraDirection.xyz)) + distanceFade);
    // --- fragment: treeParticleCommonLightPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 shColorDiff;
    float3 shColorSpec;
    float3 worldNormal = normalDepth.xyz;
    // TODO tune these values and/or get per-pixel from sim material
    float gloss        = 0.08;
    float specE        = 3;
    float specStrength = 0.2;
    // get lighting values
    float3 spec = float3(0, 0, 0);
    SceneLighting(screenUV, worldNormal, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
    Current.color.rgb = diffuseMapSample.rgb * (shColorDiff + shColorSpec) + spec;
    Current.color.a   = (diffuseMapSample.a * alphaFade);
}
