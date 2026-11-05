// Shader fragment  [PS slot 202]  planeWaterPSMinSpec

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
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
extern uniform sampler NormalMap  : register(s0);
extern uniform sampler SkyCubeMap : register(s1);
extern uniform sampler ScreenNormalMap : register(s14);
extern uniform sampler ScreenDepthMap  : register(s15);

// ---- fragment body (spliced into the generated main()) ----
{
float3 worldPos = In.texcoord<t2>.xyz;
float waterLevel = waterStrataInfoPS.mReflectionParams.x;
float reflectionScale = waterStrataInfoPS.mReflectionParams.y;   
const float NORMAL_MAP_TILING1 = 120.0;
const float NORMAL_MAP_TILING2 = 28.0;
const float NORMAL_MAP_BLEND1 = .8;
const float NORMAL_MAP_BLEND2 = 1.0;
float3 normal1 = tex2D(NormalMap, In.texcoord<t0>.xy * NORMAL_MAP_TILING1).xyz * 2.0 - 1.0;  
float3 normal2 = tex2D(NormalMap, In.texcoord<t0>.xy * NORMAL_MAP_TILING2).xyz * 2.0 - 1.0;  
float3 worldNormal = normalize(normal1 * NORMAL_MAP_BLEND1 + normal2 * NORMAL_MAP_BLEND2);
worldNormal.z *= 0.85;  
worldNormal = normalize(normal);
float3 toCamera = worldCameraPosition.xyz - In.texcoord<t2>.xyz;
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
float phong = max(0, pow(dot(R1, V), specularPower) * specularScale);
shSpec = sunSky.mSunColor.xyz * phong;
shDiffuse = skyColor;
const float3 refractedColor = float3(0,0,0);
float3 reflectedColor = skyColor;  
float3 combinedColor = lerp(refractedColor, reflectedColor, fresnelTerm);
float finalTransparency = saturate(0.15 + fresnelTerm * 1.0);
float4 waterColor = float4(combinedColor * shDiffuse + shSpec, finalTransparency);
Current.color.rgb = waterColor.rgb;
Current.color.a=0.9; 
}
