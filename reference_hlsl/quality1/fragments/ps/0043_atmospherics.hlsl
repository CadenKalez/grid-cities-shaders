// Shader fragment  [PS slot 43]  atmospherics

// ---- uniform parameters ----
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;   // reg-meta 02d702d70004000000000008
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float3 mInvDensity; float3 mSunDir; float4 mZenith;  float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather;} sunSky;   // reg-meta 028b028b000b000000000008
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

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
static const float kGroundScale = 1024;
static const float kGroundZero  = -870;
static const bool  kUseAtmosphere = true;
static const float kGroundAtmosphereStart    = kGroundZero;
static const bool  kUseVolume = false;
static const float kVolumeFogFalloffZ = 0.5;
static const float kVolumeFogDensity  = 0.80;
static const bool  kUseAutoScale = false;
static const float kAutoScaleDensity      = 1.75;
static const float kAutoScaleScaleStart   = 200;
static const float kAutoScaleDensityStart = 120;
static const float kScatterStrength = 1.5;
static const bool  kUseQuadraticDensity = true;
static const bool  kShowFogStrength = false;
float3 ScatterColor(cSunSkyInfo info, float3 v)
{
float cosGamma = dot(info.mSunDir, v);
float gamma = acos(cosGamma);
float co = saturate(1 - cosGamma) * 0.2;
float cosTheta = lerp(co, 1, abs(v.z));
if (kUseSkyTable)
return SkyColorTableCompressedWithTuning(skyTermTableXXX, info, cosTheta + 0.01, cosGamma, 0);
else
return SkyColorTG(info, cosTheta, cosGamma, gamma);
}
// hs is ground zero, alpha is atmosphere falloff vertically, B0 is base density
// at hs.
float AtmosphericDensity(float3 worldPosition, float3 viewPosition, float3 viewDirection,
float hs, float alpha, float B0)
{
float h0 = worldPosition.z - hs;
float cosTheta = viewDirection.z;
float K = B0 / (alpha * cosTheta);
float H = exp(-alpha * h0);
float us = exp(-alpha * (viewPosition.z - hs));
float density = K * (H - us);
return density;
}
// Crytek-style
float VolumetricDensity(float3 worldPosition, float3 viewPosition, float alpha, float baseDensity)
{
float3 delta = viewPosition - worldPosition;
float s0 = length(delta);
float z = viewPosition.z - kGroundZero;
s0 *= exp(-alpha * z);
float t = alpha * delta.z;
s0 *= (1 - exp(-t)) / t;
return s0 * baseDensity;
}
float AutoScaleDensity(float3 worldPosition, float3 viewPosition, float3 viewDirection, float baseDensity, float scaleStart, float densityStart)
{
float z = viewPosition.z - kGroundZero;
float dz = -viewDirection.z;
float d = max(z, 0.0) / max(0.1, dz);
float scale = max(d / scaleStart, 1.0);
float3 delta = viewPosition - worldPosition;
float s0 = max(length(delta) - densityStart * scale, 0.0);
return s0 * baseDensity / scale;
}
float SceneDensity(float3 worldPosition, float3 viewPosition, float3 viewDirection, float baseDensity, float densityStart)
{
float3 delta = viewPosition - worldPosition;
float s0 = max(length(delta) - densityStart, 0.0);
return s0 * baseDensity;
}

// ---- fragment body (spliced into the generated main()) ----
float3 scatterDir = worldPosition;
float boxSize = 3 * 1024;
float2 as = saturate(abs(scatterDir.xy / boxSize));
float2 bs = 1 - as;
float ew = bs.x * bs.y; 
Current.color.rgb = ScatterColor(sunSky, viewDirection);
float density;
float density2;
float scatterStrength = kScatterStrength;
float kGroundAtmosphereDensity  = sunSky.mDynamicWeather.x; 
float kGroundAtmosphereFalloffZ = sunSky.mDynamicWeather.y;   
float kGroundAtmosphereDensity2  = sunSky.mDynamicWeather.z; 
float kGroundAtmosphereFalloffZ2 = sunSky.mDynamicWeather.w;   
if (kUseAtmosphere)
{
density = AtmosphericDensity
(
worldPosition, viewPosition, viewDirection,
kGroundAtmosphereStart,
kGroundAtmosphereFalloffZ / kGroundScale,
kGroundAtmosphereDensity  / kGroundScale
);
density2 = AtmosphericDensity
(
worldPosition, viewPosition, viewDirection,
kGroundAtmosphereStart,
kGroundAtmosphereFalloffZ2 / kGroundScale,
kGroundAtmosphereDensity2  / kGroundScale
);
float farDepthZ=0.99; 
if ( depth > farDepthZ )
{
density=density2;
}
}
else if (kUseVolume)
density = 0;
/*
(
worldPosition, viewPosition,
kVolumeFogFalloffZ / kGroundScale,
kVolumeFogDensity  / kGroundScale
);
*/
else if (kUseAutoScale)
density = 0;
/*
(
worldPosition, viewPosition, worldCameraDirection.xyz,
kAutoScaleDensity  / kGroundScale,
kAutoScaleScaleStart,
kAutoScaleDensityStart
);
*/
else
{
density = SceneDensity
(
worldPosition, viewPosition, worldCameraDirection.xyz,
sunSky.mPerezB.w,
sunSky.mPerezC.w
);
scatterStrength = sunSky.mPerezA.w;
}
float tau;
if (kUseQuadraticDensity)
tau = exp(-(density * density)); 
else
tau = exp(-density);
Current.color.a = tau;
Current.color.rgb *= (1 - tau) * scatterStrength; 
if (kShowFogStrength)  
{
Current.color.a = 0;
Current.color.rgb = make_float3(1 - tau);
}
