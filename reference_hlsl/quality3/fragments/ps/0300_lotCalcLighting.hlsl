// Shader fragment  [PS slot 300]  lotCalcLighting

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;   // reg-meta 02d702d70004000000000008
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mNormalParams; float4 mColor; } terrainInfoPS;   // reg-meta 028202820004000000000008
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 samplerInfo2;   // reg-meta 026002600001000000400000
uniform float4 samplerInfo4;   // reg-meta 026202620001000000400000
uniform float4 samplerInfo7;   // reg-meta 026502650001000000400000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 worldFarCorners[4];   // reg-meta 02b602b60004000000000008
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- declarations / helper functions ----
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
uniform sampler combinedEcoMaps   : register(s0);
uniform sampler noiseMap          : register(s1);
uniform sampler controlMap        : register(s2);
uniform sampler topDownTerrainNormals  : register(s3);  
uniform sampler heightMap              : register(s4);  
uniform samplerCUBE colorCubeMap       : register(s5);  
static const bool kShowLighting = false;
static const float kAmbient                = 0.0;
static const float kLightingColorScale     = 0.35;
static const float3 kAverageGrassColor = (
float3(143/255.0, 196/255.0, 70/255.0) +
float3(87/255.0, 124/255.0, 55/255.0)  +
float3(131/255.0, 174/255.0, 84/255.0) +
float3(105/255.0, 149/255.0, 55/255.0)
);
static const float3 kGrassColorScale = float3(0.3, 0.4, 0.0) * 0.25;
static const float3 kDryGroundColor         = float3(1.0, 0.8, 0.0) * 0.3;
static const float3 kMoistGroundColor       = kAverageGrassColor * kGrassColorScale;
static const float3 kPollutedGroundColor    = float3(1,1,1) * 0.25;
static const float3 kSnowGroundColor        = float3(1,1,1) * 1.0;
static const float kBladeGroundBlend        = 0.0;
static const float kBladeTextureBlend       = 0.3;
static const float kBladeFadeScalar         = 0.0015;
static const float kGroundBladeFadeScalar   = 0.0003;
static const float3 kGrassImposterVertexScale   = float3(1.0, 1.0, 0.7);
static const float kBlendWithTerrainNormal = 0.95;
static const float kBorderWidth             = 2.0;
static const float kColorNoiseUVScale       = 3.0;
static const float kCrinklyNoiseUVScale     =  4.0;
static const float kCrinklyNoiseDown        = -0.5;
static const float kCrinklyNoiseScale       =  0.75;
static const float kCrinklyNoiseUp          =  0.4;
static const float kPatchyNoiseUVScale     =  0.5;
static const float kPatchyNoiseDown        = -0.225;
static const float kPatchyNoiseScale       =  1.5;
static const float kPatchyNoiseUp          = -0.3;
static const float kTriPlanarCliffTiling = 180.0;
static const float kTriPlanarCliffTilingDetail = 40.0;
static const float kTriPlanarGroundTiling = 250.0;
static const float kTriPlanarGroundTilingDetail = 30.0;
static const float kTriPlanarGroundTilingDetailMinSpec = 80.0;
static const float kTriPlanarPollutionTiling = 100.0;
static const float kTriPlanarSnowTiling = 100.0;
static const float kTriPlanarBlendWeights = -0.15;
static const float kTriPlanarDistanceBlend = 1.0/9000;
static const float kTriPlanarCliffMinDist = -1;
static const float kTriPlanarCliffMaxDist = .1;
static const float kTriPlanarSoilMinDist  = -0.75;
static const float kTriPlanarSoilMaxDist  = -0.5;
static const float kTriPlanarGrassMinDist = -0.85;
static const float kTriPlanarGrassMaxDist = -0.5;
static const float kTriPlanarPollutionMinDist = -0.85;
static const float kTriPlanarPollutionMaxDist = -0.5;
static const float kTriPlanarSnowMinDist = -0.85;
static const float kTriPlanarSnowMaxDist = -0.5;
static const float kBeachGrassLine = 2.0;
static const float kBeachDrySand = 0.3;
static const float kBeachWetSand = -1.0;
static const float BEACH_NOISE_TILING = 0.4;
static const float WATER_NORMAL_MAP_TILING1 = 120.0;
static const float WATER_NORMAL_MAP_TILING2 = 28.0;
static const float WATER_NORMAL_MAP_BLEND1 = 0.8;
static const float WATER_NORMAL_MAP_BLEND2 = 1.0;
static const float WATER_COARSE_NORMAL_SPACING = 1.0/256.0;
static const float WATER_COARSE_HEIGHT_SCALE   = 0.0023;
static const float WATER_HEIGHT_MAP_TILING     = 40.0;
static const float WATER_HEIGHT_MAP_TILING_FOAM = 5.0;
static const float WATER_HEIGHT_MAP_SCALE      = 1.0;
static const float WATER_HEIGHT_MAP_BIAS       = -4.0;
static const float WATER_CHOPPY_MAP_TILING     = 5.0;
static const float WATER_CHOPPY_MAP_SCALE      = 2;
static const float FOAM_CHOPPY_MAP_SCALE       = 0.0;
static const float FOAM_TILING                 = 280.0;
static const float FOAM_SATURATION             = 7.75;
static const float FOAM_MAX_DEPTH              = 3.5;
static const float FOAM_DIFFUSE_EFFECT         = 0.7;
static const float FOAM_HEIGHT_TAP_COUNT       = 5;
static const float FOAM_HEIGHT_TAP_SPACING     = (1.0/256.0) * 0.075;
float4 getControlChannels(sampler controlMap, sampler noiseMap, in float2 controlMapUV, in float2 heightMapUV)
{
float4 controlChannels = tex2D(controlMap, controlMapUV).rgba;
float2 satResult = saturate(controlMapUV);
float useControlMap = satResult.x == controlMapUV.x ? 1 : 0;
useControlMap *= satResult.y == controlMapUV.y ? 1 : 0;
controlChannels.a *= useControlMap;
controlChannels.a = saturate(lerp(0.0, kBorderWidth, controlChannels.a));
float noise = tex2D(noiseMap, controlMapUV * kCrinklyNoiseUVScale).x;
noise += kCrinklyNoiseDown;
noise *= kCrinklyNoiseScale;
noise += kCrinklyNoiseUp;
controlChannels.a = saturate(controlChannels.a + noise);
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
return controlChannels;
}
float4 getControlChannelsMinSpec(sampler controlMap, sampler noiseMap, in float2 controlMapUV, in float2 heightMapUV)
{
float4 controlChannels = tex2D(controlMap, controlMapUV).rgba;
float2 satResult = saturate(controlMapUV);
float useControlMap = satResult.x == controlMapUV.x ? 1 : 0;
useControlMap *= satResult.y == controlMapUV.y ? 1 : 0;
controlChannels.a *= useControlMap;
controlChannels.a = saturate(lerp(0.0, kBorderWidth, controlChannels.a));
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
return controlChannels;
}
float getGrassAmount(sampler combinedEcoMaps, in float2 heightMapUV, in float3 terrainNormal, float controlAmount, inout float4 ecoMapsOut, sampler noiseMap, in float2 controlMapUV)
{
ecoMapsOut = tex2D(combinedEcoMaps, heightMapUV).rgba;
float grassAmount = ecoMapsOut.r * ecoMapsOut.b;
grassAmount = sqrt(grassAmount);
float patchy = tex2D(noiseMap, controlMapUV * kPatchyNoiseUVScale).x;
patchy += kPatchyNoiseDown;
patchy *= kPatchyNoiseScale;
patchy += kPatchyNoiseUp;
grassAmount = sign(grassAmount) * saturate(grassAmount + patchy);
float flatness = saturate(terrainNormal.z);
flatness *= flatness;
flatness *= flatness;
flatness *= flatness;
flatness *= flatness;
grassAmount *= flatness;
grassAmount = saturate(grassAmount);
grassAmount *= 1.0 - controlAmount;
return grassAmount;
}
float getGrassAmountMinSpec(sampler combinedEcoMaps, in float2 heightMapUV, in float3 terrainNormal, float controlAmount, inout float4 ecoMapsOut, sampler noiseMap, in float2 controlMapUV)
{
ecoMapsOut = tex2D(combinedEcoMaps, heightMapUV).rgba;
float grassAmount = ecoMapsOut.r * ecoMapsOut.b;
float patchy = tex2D(noiseMap, controlMapUV * kPatchyNoiseUVScale ).x;
patchy += kPatchyNoiseDown;
patchy *= kPatchyNoiseScale;
patchy += kPatchyNoiseUp;
grassAmount =  sign(grassAmount) * saturate(grassAmount + patchy);
grassAmount *= 1.0 - controlAmount;
return grassAmount;
}
float computeGrassAmount(sampler controlMap, sampler combinedEcoMaps, sampler noiseMap, in float3 terrainNormal, in float2 controlMapUV, in float2 heightMapUV, inout float4 ecoMapsOut)
{
float4 controlChannels = getControlChannels(controlMap, noiseMap, controlMapUV, heightMapUV);
return getGrassAmount(combinedEcoMaps, heightMapUV, terrainNormal, controlChannels.a, ecoMapsOut, noiseMap, controlMapUV);
}
float computeGrassAmountMinSpec(sampler controlMap, sampler combinedEcoMaps, sampler noiseMap, in float3 terrainNormal, in float2 controlMapUV, in float2 heightMapUV, inout float4 ecoMapsOut)
{
float4 controlChannels = getControlChannelsMinSpec(controlMap, noiseMap, controlMapUV, heightMapUV);
return getGrassAmountMinSpec(combinedEcoMaps, heightMapUV, terrainNormal, controlChannels.a, ecoMapsOut, noiseMap, controlMapUV);
}
float densityThreshold(in float4 pixelNormal, in float grassAmount, in float fade)
{
float bladeID = pixelNormal.a;
float mask = bladeID - 0.004;
float select = grassAmount * fade - bladeID;
return min(mask, select);
}
float3 computeGrassNormal(float3 terrainNormal, in float3 grassNormal)
{
grassNormal = lerp(grassNormal, terrainNormal, kBlendWithTerrainNormal);
grassNormal = normalize(grassNormal);
return grassNormal;
}
float3 computeBasicGroundColor(in float4 ecoMaps, float grassAmount)
{
float3 groundColor = lerp(kDryGroundColor, kMoistGroundColor, grassAmount);
groundColor = lerp(groundColor, kAverageGrassColor * kGrassColorScale, kBladeGroundBlend);
groundColor = lerp(groundColor, kPollutedGroundColor, ecoMaps.a);
return groundColor;
}
float3 testRayPlane(in float3 rayOrigin, in float3 rayDir, in float3 Pp, in float3 Pn, inout float tDist)
{
float Pd = -dot(Pp, Pn);
float Vd = dot(Pn, rayDir);
float V0 = -(dot(Pn, rayOrigin) + Pd);
tDist = V0 / Vd;
float3 rayHit = rayOrigin + (rayDir * tDist);
return rayHit;
}
float3 ComputeBeachValues(sampler noiseMap, float2 controlMapUV, float waterLevel, float worldZ)
{
float noise = tex2D(noiseMap, controlMapUV * BEACH_NOISE_TILING).x;
noise -= 0.25;
noise *= 2.75;
noise += 0.3;
float trees = worldZ - (waterLevel + kBeachGrassLine + noise);
float drySand = (waterLevel + kBeachDrySand + noise) - worldZ;
float wetSand = (waterLevel + kBeachWetSand + noise) - worldZ;
float3 res = float3(drySand, trees, wetSand);
return res;
}
float3 GetSnowAmount(in float worldPosZ, in float snowLevel)
{
float3 snow = float3(0,0,0);
snow.x = saturate((worldPosZ - snowLevel) / 80.0);
snow.y = snow.x * 0.65;
snow.z = snow.x;
return snow;
}
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
float ComputeAOTerm(sampler heightMap, in float2 heightMapUV, in float2 aoTapSpacing)
{
const float power = 0.9;
const float contrast = 0.18;
const int aoSamples = 10;
const float darkness = (4 * 8.0) / aoSamples;
const float step = (3.14159 * 2.0) / aoSamples;
const float startAngle = 40.0 / 57.3;
float spacing = (1.0 / 256.0) * contrast * aoTapSpacing.y;
float currentHeight = tex2D(heightMap, heightMapUV).x;
float2 sc = float2(0,0);
float occluded = 0;
for (int i = 0; i < aoSamples; i++)
{
float a = startAngle + step * i;
sincos(a, sc.x, sc.y);
float2 uv = float2(sc.x * spacing * (1+i%2), sc.y * spacing * (1+i%2));
float sample = tex2D(heightMap, heightMapUV + uv).x;
float o = saturate(sample - currentHeight);
occluded += o;
}
occluded = pow(occluded, power);
occluded *= darkness;
return saturate(occluded);
}
float3 ComputeAOColor(float term)
{
const float3 aoColorMin = float3(1.0, 1.0, 1.0);
const float3 aoColorMax = float3(0.405, 0.34, 0.32) * 0.1;
float3 finalAOColor = lerp(aoColorMin, aoColorMax, term);
return finalAOColor;
}
float3 ComputeAOColorForHeavyLayer(float term)
{
const float3 aoColorMin = float3(1.0, 1.0, 0.95) * 1.1;
const float3 aoColorMax = float3(1.0, 1.0, 1.0) * -1.15;
float3 finalAOColor = lerp(aoColorMin, aoColorMax, term*term);
return finalAOColor;
}

// ---- fragment body (spliced into the generated main()) ----
float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
float4 deferredInfo = GetDeferredNormalAndSpec(screenUV);
float3 worldNormal = deferredInfo.xyz;
// get the overlay tile index we stashed in the deferred alpha and then use that to tint the overlay color
float overlayMapIndex = floor((deferredInfo.w + 1.0/64.0)*16);
float2 overlayMapUVMin = float2(frac(overlayMapIndex * .25),floor(overlayMapIndex * .25)*0.25);
float2 overlayMapUVMax = overlayMapUVMin + float2(0.25,0.25);
float2 overlayMapCoord = lerp(overlayMapUVMin,overlayMapUVMax,frac(baseUV));
float4 overlayMap = tex2D(overlayTintSampler,overlayMapCoord);
// christian!  you might want to set this to 2.0 * overlayMap.rgb and then set all your overlay textures to 0.5 initially
Current.color.rgb *= lerp(1.0,overlayMap.a * 2.0,overlayMask);
float2 heightMapUV = In.texcoord7.xy / 1024.0 * 0.5 + 0.5;
float2 controlMapUV = In.texcoord7.xy / 1024.0 * 0.5 + 0.5;  
float4 worldPos = float4(In.texcoord7.xyz, 1);
float waterLevel = terrainInfoPS.mWaterInfo.x;
float snowLevel = terrainInfoPS.mWaterInfo.y;
//float2 halfPixelOffset = (samplerInfo7.zw * 0.5);
//float2 forestMapOffset = normalize(sunSky.mSunDir.xy) * 0.0025;
//float4 forestColor = tex2D(forestColorMap, heightMapUV + halfPixelOffset).rgba;
//float forestAlpha = forestColor.a * waterMask;
float4 normalMapSample = tex2D(topDownTerrainNormals, heightMapUV).xyzw;  
float3 terrainNormal = normalMapSample.xyz * 2.0 - 1.0;  
float4 ecoMapValues;  
float grassAmount = computeGrassAmount(controlMap, combinedEcoMaps, noiseMap, terrainNormal, controlMapUV, heightMapUV, ecoMapValues);
// sh lighting
// get lighting values
// christian!  multiply overlayMap into whichever ones of these you want to be affected
specE = 512 * Current.color.a * overlayMap.r;
specStrength =.1 * Current.color.a * overlayMap.g;
float reflectance = 0.2 * Current.color.a; 
gloss *= Current.color.a; 
float3 shDiffuse = float3(0, 0, 0);
float3 shSpec    = float3(0, 0, 0);
float3 spec      = float3(0, 0, 0);
float3 worldViewDirection = normalize(lerp(lerp(worldFarCorners[1],worldFarCorners[0],screenUV.y),lerp(worldFarCorners[3],worldFarCorners[2],screenUV.y),screenUV.x)).xyz;
SceneLighting(screenUV, worldNormal.xyz, worldViewDirection.xyz, gloss, reflectance, specE, specStrength, shDiffuse, shSpec, spec);
float4 clipPosition1 = mul(float4(worldPos.xyz,1), worldToClip);
float currentDepth = clipPosition1.w * nearFar.w * 255.0;
float increaseWithDistance =0;// saturate(clipPosition1.w * kTriPlanarDistanceBlend);
float3 triplanarPos = worldPos.xyz + 16384;
float2 coords2D[8];
coords2D[0] = frac(triplanarPos.yz / kTriPlanarCliffTilingDetail) * 2.0 - 1.0;   
coords2D[1] = frac(triplanarPos.zx / kTriPlanarCliffTilingDetail) * 2.0 - 1.0;   
coords2D[2] = frac(triplanarPos.yz / kTriPlanarCliffTiling) * 2.0 - 1.0;         
coords2D[3] = frac(triplanarPos.zx / kTriPlanarCliffTiling) * 2.0 - 1.0;         
coords2D[4] = frac(triplanarPos.xy / kTriPlanarGroundTilingDetail) * 2.0 - 1.0;  
coords2D[5] = frac(triplanarPos.xy / kTriPlanarGroundTiling) * 2.0 - 1.0;        
coords2D[6] = frac(triplanarPos.xy / kTriPlanarPollutionTiling) * 2.0 - 1.0;     
coords2D[7] = frac(triplanarPos.xy / kTriPlanarSnowTiling) * 2.0 - 1.0;          
float3 coords3D[12];
coords3D[0] = (float3(coords2D[0].x, coords2D[0].y, 1.0));  
coords3D[1] = (float3(coords2D[1].y, coords2D[1].x, 1.0));  
coords3D[2] = (float3(coords2D[2].x, coords2D[2].y, 1.0));  
coords3D[3] = (float3(coords2D[3].y, coords2D[3].x, 1.0));  
coords3D[4] = (float3(1.0, coords2D[4].x, coords2D[4].y));  
coords3D[5] = (float3(1.0, coords2D[5].x, coords2D[5].y));  
coords3D[6] = (float3(coords2D[4].x,  1.0, coords2D[4].y));  
coords3D[7] = (float3(coords2D[5].x,  1.0, coords2D[5].y));  
coords3D[8] = (float3(coords2D[4].x, -1.0, coords2D[4].y));  
coords3D[9] = (float3(coords2D[6].x, -1.0, coords2D[6].y));  
coords3D[10] = (float3(-1.0, coords2D[4].x, coords2D[4].y));  
coords3D[11] = (float3(-1.0, coords2D[7].x, coords2D[7].y));  
float3 cubeMapSamples[12];
cubeMapSamples[0] = texCUBE(colorCubeMap, coords3D[0]).xyz;  
cubeMapSamples[1] = texCUBE(colorCubeMap, coords3D[1]).xyz;  
cubeMapSamples[2] = texCUBE(colorCubeMap, coords3D[2]).xyz;  
cubeMapSamples[3] = texCUBE(colorCubeMap, coords3D[3]).xyz;  
cubeMapSamples[4] = texCUBE(colorCubeMap, coords3D[4]).xyz;  
cubeMapSamples[5] = texCUBE(colorCubeMap, coords3D[5]).xyz;  
cubeMapSamples[6] = texCUBE(colorCubeMap, coords3D[6]).xyz;  
cubeMapSamples[7] = texCUBE(colorCubeMap, coords3D[7]).xyz;  
cubeMapSamples[8] = texCUBE(colorCubeMap, coords3D[8]).xyz;  
cubeMapSamples[9] = texCUBE(colorCubeMap, coords3D[9]).xyz;  
cubeMapSamples[10] = texCUBE(colorCubeMap, coords3D[10]).xyz;  
cubeMapSamples[11] = texCUBE(colorCubeMap, coords3D[11]).xyz;  
float cliffSmoothStep = smoothstep(kTriPlanarCliffMinDist, kTriPlanarCliffMaxDist, increaseWithDistance);
float soilSmoothStep  = smoothstep(kTriPlanarSoilMinDist,  kTriPlanarSoilMaxDist,  increaseWithDistance);
float grassSmoothStep = smoothstep(kTriPlanarGrassMinDist, kTriPlanarGrassMaxDist, increaseWithDistance);
float pollutionSmoothStep = smoothstep(kTriPlanarPollutionMinDist, kTriPlanarPollutionMaxDist, increaseWithDistance);
float snowSmoothStep = smoothstep(kTriPlanarSnowMinDist, kTriPlanarSnowMaxDist, increaseWithDistance);
float3 blends[6];
blends[0] = cubeMapSamples[2] + (cubeMapSamples[0] - cubeMapSamples[2]) * cliffSmoothStep;  
blends[1] = cubeMapSamples[3] + (cubeMapSamples[1] - cubeMapSamples[3]) * cliffSmoothStep;  
blends[2] = cubeMapSamples[5] + (cubeMapSamples[4] - cubeMapSamples[5]) * soilSmoothStep;   
blends[3] = cubeMapSamples[7] + (cubeMapSamples[6] - cubeMapSamples[7]) * grassSmoothStep;  
blends[4] = cubeMapSamples[9] + (cubeMapSamples[8] - cubeMapSamples[9]) * pollutionSmoothStep;  
blends[5] = cubeMapSamples[11] + (cubeMapSamples[10] - cubeMapSamples[11]) * snowSmoothStep;  
float treeDirtPatchAmount = 1; //saturate((1.0 - forestAlpha) * kTreeDirtPatchScale);
float3 groundColor = lerp(blends[2], blends[3], grassAmount * treeDirtPatchAmount);
float3 blendWeights = abs(float3(terrainNormal));
blendWeights = max(blendWeights + kTriPlanarBlendWeights, float3(0.0, 0.0, 0.0));
blendWeights /= (blendWeights.x + blendWeights.y + blendWeights.z);
float3 triplanarColor =
blends[0].xyz * blendWeights.xxx +
blends[1].xyz * blendWeights.yyy +
groundColor * blendWeights.zzz;
float pollutionAmount = ecoMapValues.w;
float3 snowAmount = GetSnowAmount(worldPos.z, snowLevel);  
triplanarColor = lerp(triplanarColor, blends[4], pollutionAmount);
float treeShadowAmount = 1;//(1.0 - treeShadowMask * kTreeShadowDarkening);
float3 finalGroundColor = lerp(triplanarColor,Current.color.rgb,Current.color.a);
finalGroundColor = finalGroundColor * shDiffuse * kLightingColorScale * treeShadowAmount;
float3 final = finalGroundColor;
final += (shSpec + spec) * Current.color.a;
float aoTerm = normalMapSample.w;
float3 aoColor = ComputeAOColor( aoTerm );
final *= aoColor;  
Current.color.rgb = final;
Current.color.a = 1.0;
