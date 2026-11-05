// Shader fragment  [PS slot 207]  hdWaterPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;   // reg-meta 02d702d70004000000000008
uniform struct { float4 mColor; float4 mReflectionParams; float4 mSpecularNormal; float4 mSunDir; } waterStrataInfoPS;   // reg-meta 028d028d0004000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000

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
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
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
extern uniform sampler WaterHeightMap   : register(s0);
extern uniform sampler WaterNormalMap   : register(s1);
extern uniform sampler FoamTexture      : register(s2);
extern uniform sampler TerrainHeightMap : register(s3);
extern uniform sampler HDRColor        : register(s12);
extern uniform sampler ScreenNormalMap : register(s14);
extern uniform sampler ScreenDepthMap  : register(s15);

// ---- fragment body (spliced into the generated main()) ----
{
float2 waterHeightMapUV = In.texcoord<t0>.xy;
float2 terrainHeightMapUV = In.texcoord<t0>.zw;
float waterLevel = In.texcoord<t1>.x;  
float2 heightTapSpacing = In.texcoord<t1>.zw;
float3 worldPos = In.texcoord<t2>.xyz;
const float step = 3.14159 * 2.0 / FOAM_HEIGHT_TAP_COUNT;
const float startAngle = 40.0 / 57.3;  
float spacing = FOAM_HEIGHT_TAP_SPACING * heightTapSpacing.y;
float2 sc = float2(0,0);
float integral = 0;
for (int i = 0; i < FOAM_HEIGHT_TAP_COUNT; i++)
{
float a = startAngle + step * i;
sincos(a, sc.x, sc.y);
float2 uv = float2(sc.x * spacing, sc.y * spacing);
integral += tex2D(TerrainHeightMap, terrainHeightMapUV + uv).x;
}
float terrainHeight = integral / FOAM_HEIGHT_TAP_COUNT;  
terrainHeight *= 2048.0;  
terrainHeight -= 1024.0;  
float waterHeight = tex2D(WaterHeightMap, terrainHeightMapUV * WATER_HEIGHT_MAP_TILING_FOAM).x;
waterHeight *= WATER_HEIGHT_MAP_SCALE;
waterHeight += WATER_HEIGHT_MAP_BIAS;
waterHeight = min(waterHeight, 0);
waterHeight += waterLevel;
float waterDepth = waterHeight - terrainHeight;
waterDepth = max(0.0, waterDepth - 1.0);  
float3 worldNormal = tex2D(ScreenNormalMap, screenUV).xyz * 2.0 - 1.0;  
float3 toCamera = worldCameraPosition.xyz - worldPos;
float3 L = sunSky.mSunDir.xyz;  
const float3 cameraVectorScale = float3(1.0, 1.0, 0.9);  
float3 V = normalize(toCamera * cameraVectorScale);  
const float fresnelScale = 5.0;  
float fresnelTerm = dot(V, worldNormal);  
fresnelTerm *= fresnelTerm;
fresnelTerm *= fresnelScale;
fresnelTerm = sqrt(fresnelTerm);
fresnelTerm = sqrt(fresnelTerm);
fresnelTerm = 0.925 - saturate(fresnelTerm);
fresnelTerm = max(0.01, fresnelTerm);  
fresnelTerm = min(1.0, fresnelTerm);  
float3 shDiffuse;
float3 shSpec;
float3 RS = reflect(-V, worldNormal) * 1.0;
float3 skyColor = SkyColor(sunSky, RS);
float3 R1 = reflect(L, worldNormal.xyz);
float3 H = normalize(L + V.yxz);  
float specularPower = waterStrataInfoPS.mSpecularNormal.x;
float specularScale = waterStrataInfoPS.mSpecularNormal.y;
float phong = max(0.0, pow(dot(R1, V), specularPower) * specularScale);
shSpec = sunSky.mSunColor.xyz * phong;
shDiffuse = skyColor;
const float3 refractedColor = float3(0,0,0);
float3 reflectedColor = skyColor;  
float3 combinedColor = lerp(refractedColor, reflectedColor, fresnelTerm);
float finalTransparency = saturate(0.15 + fresnelTerm * 1.0);
float foamAmount = saturate((FOAM_MAX_DEPTH - waterDepth) / FOAM_SATURATION);
float2 foamUV = frac(waterHeightMapUV * FOAM_TILING);
float4 foamColor = tex2D(FoamTexture, foamUV).rgba;
foamAmount *= foamColor.a;  
foamAmount *= foamAmount;  
shSpec *= 1.0 - saturate(foamAmount * 2.5);
float4 waterColor = float4(combinedColor * shDiffuse + shSpec, finalTransparency);
float indexOfRefraction=0.2; 
float3 refractedRay = refract(V, worldNormal, indexOfRefraction);
float2 flatRefraction = float2(refractedRay.xy);
float TIR = length(flatRefraction)==0 ? .5 : 0.0;  // "Internal" to the air, not the water i.e. fully reflected
flatRefraction = (TIR != 0.0) ? flatRefraction : normalize(flatRefraction);
float refractionScale=0.03;  
float2 bufferCoords = screenUV;
float2 refractionInfluence = float2(sin(worldNormal.x * 3.14159), sin(worldNormal.y * 3.14159));
refractionInfluence*=refractionScale;
float2 refractionCoords = bufferCoords +  refractionInfluence;
float2 hdrColorUV=refractionCoords;
float4 hdrTexture = tex2D(HDRColor, hdrColorUV).xyzw;
float4 rgbaDepth = tex2D(ScreenDepthMap, hdrColorUV);
float depthInScene = UnpackDepth(rgbaDepth);
float existingDepth = depthInScene * nearFar.y;
float4 clipPosition1 = mul(float4(worldPos.xyz,1), worldToClip);
float waterCameraZ = clipPosition1.w;
foamAmount *= 1.0 - smoothstep(2000, 10000, waterCameraZ);
float waterZ=existingDepth - waterCameraZ ;  
if ( waterZ<=0 )
{
hdrTexture.rgba= tex2D(HDRColor, screenUV).rgba;
rgbaDepth = tex2D(ScreenDepthMap, screenUV);
depthInScene = UnpackDepth(rgbaDepth);
existingDepth = depthInScene * nearFar.y;
waterZ=existingDepth - waterCameraZ ;  
}
float underWaterFactor = smoothstep( 0.0, 70.0, waterZ );
underWaterFactor = lerp(0.30, 0.005, underWaterFactor);
float3 basinSolidColor=float3(0.06, .15, .12) * .15 ; 
float3 basinUnderWaterFinalColor = lerp(basinSolidColor, hdrTexture.rgb, underWaterFactor); 
Current.color.rgb = lerp(basinUnderWaterFinalColor, waterColor.rgb, finalTransparency) ; 
foamColor.rgb = lerp(foamColor.rgb, foamColor.rgb * shDiffuse, FOAM_DIFFUSE_EFFECT);
Current.color.rgb = lerp(Current.color.rgb, foamColor.rgb, foamAmount);
Current.color.a=1.0; 
}
