// Shader fragment  [PS slot 169]  terrainMinSpecPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;   // reg-meta 02d702d70004000000000008
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mNormalParams; float4 mColor; } terrainInfoPS;   // reg-meta 028202820004000000000008
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
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
uniform sampler forestColorMap         : register(s0);  
uniform sampler topDownTerrainNormals  : register(s1);  
uniform sampler heightMap              : register(s2);  
uniform sampler controlMap             : register(s3);  
uniform samplerCUBE colorCubeMap       : register(s4);  
uniform sampler noiseMap               : register(s5);  
uniform sampler combinedEcoMaps        : register(s6);  
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

// ---- fragment body (spliced into the generated main()) ----
half2 heightMapUV = In.texcoord<t0>.xy;   
half2 controlMapUV = In.texcoord<t0>.zw;  
half4 worldPos = half4(In.texcoord<t2>.xyz, 1);
half3 terrainNormal = tex2D(topDownTerrainNormals, heightMapUV).xyz * 2.0 - 1.0;  
half4 ecoMapValues;  
half grassAmount = computeGrassAmountMinSpec(controlMap, combinedEcoMaps, noiseMap, terrainNormal, controlMapUV, heightMapUV, ecoMapValues);
const half3 terrainLightingParams = half3(0.0f, 0.0f, 0.0f);
half3 lightingParams = terrainLightingParams; 
half gloss           = lightingParams.x;
half specE           = lightingParams.y;
half specStrength    = lightingParams.z;
half3 shDiffuse = half3(0, 0, 0);
half3 shSpec = half3(0, 0, 0);
half3 spec = half3(0, 0, 0);
SceneLighting(screenUV, terrainNormal.xyz, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shDiffuse, shSpec, spec);
half3 triplanarPos = worldPos.xyz ;
half2 coords2D[6];
coords2D[4] = frac(triplanarPos.xy / kTriPlanarGroundTilingDetailMinSpec) * 2.0 - 1.0;  
const half kUVScaleFactor=0.55; 
coords2D[4] *= kUVScaleFactor;
half3 beachValues = half3(1,1,1); 
half3 coords3D[8];
coords3D[4] = (half3(1.0, coords2D[4].x, coords2D[4].y));  
coords3D[6] = (half3(coords2D[4].x, 1.0, coords2D[4].y));  
half3 cubeMapSamples[8];
cubeMapSamples[4] =  texCUBE(colorCubeMap, coords3D[4]).xyz;  
cubeMapSamples[6] = texCUBE(colorCubeMap, coords3D[6]).xyz;  
half cliffSmoothStep =1; 
half soilSmoothStep  = 1; 
half grassSmoothStep =1; 
half3 blends[4];
blends[0] = cubeMapSamples[4]; 
blends[1] = cubeMapSamples[4]; 
blends[2] = cubeMapSamples[4]; 
blends[3] = cubeMapSamples[6]; 
half3 groundColor = lerp(blends[2], blends[3], grassAmount );
half3 blendWeights = abs( terrainNormal);
half pollution = 1.0 - (0.5 * ecoMapValues.w);
groundColor *= pollution;
half3 triplanarColor =
blends[0].xyz * blendWeights.xxx +
blends[1].xyz * blendWeights.yyy +
groundColor * blendWeights.zzz;
half3 finalGroundColor = triplanarColor * shDiffuse * kLightingColorScale;
Current.color.rgba = float4(finalGroundColor, 1.0);
