// Shader fragment  [PS slot 243]  building4CombinePS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;   // reg-meta 02d702d70004000000000008

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
static const bool kBilinearPaletteSample = true;
static const bool kOptimizedPaletteSample = true;
static const int2  kPaletteSize = int2(256, 8);
static const float2 kPaletteInvSize = 1.0 / kPaletteSize;
static const float kSurfacePalV = 1.0 - kPaletteInvSize.y;
void BuildingPaletteSamplePoint(float palU, float palV, float3 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(kOptimizedPaletteSample)
{
float subsample_u = tintValues.r;
float subsample_v = tintValues.g;
float r_g_b = tintValues.b * 2;
tintValues.b = subsample_u * r_g_b;
float r_g = r_g_b - tintValues.b;
tintValues.g = subsample_v * r_g;
tintValues.r = r_g - tintValues.g;
}
static const float2 kUvOffset_r = float2(0.25, 0.25) * kPaletteInvSize;
static const float2 kUvOffset_g = float2(0.25, 0.75) * kPaletteInvSize;
static const float2 kUvOffset_b = float2(0.75, 0.25) * kPaletteInvSize;
float4 uvsBase = float4(palU, palV, palU, kSurfacePalV);
float4 uvs_r = uvsBase + kUvOffset_r.xyxy;
float4 uvs_g = uvsBase + kUvOffset_g.xyxy;
float4 uvs_b = uvsBase + kUvOffset_b.xyxy;
// get tint matrices
float3x4 colorMatrix;
colorMatrix[0] = tex2D(tintPaletteSampler, uvs_r.xy);
colorMatrix[1] = tex2D(tintPaletteSampler, uvs_g.xy);
colorMatrix[2] = tex2D(tintPaletteSampler, uvs_b.xy);
colorValues = mul(tintValues.rgb, colorMatrix);
float3x4 surfaceMatrix;
surfaceMatrix[0] = tex2D(tintPaletteSampler, uvs_r.zw);
surfaceMatrix[1] = tex2D(tintPaletteSampler, uvs_g.zw);
surfaceMatrix[2] = tex2D(tintPaletteSampler, uvs_b.zw);
surfaceValues = mul(tintValues.rgb, surfaceMatrix);
}
void BuildingPaletteSampleBilerp(float palU, float palV, float3 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(!kOptimizedPaletteSample)
{
float r_g = tintValues.r + tintValues.g;
float r_g_b = (tintValues.r + tintValues.g + tintValues.b);
float subsample_u = r_g_b > 0 ? (tintValues.b / r_g_b) : 0.5;
float subsample_v = r_g > 0 ? (tintValues.g / r_g) : 0.5;
tintValues.r = subsample_u;
tintValues.g = subsample_v;
tintValues.b = saturate(r_g_b * 0.5);
}
static const float2 kSubsampleScale = kPaletteInvSize * 0.5;
static const float2 kSubsampleOffset = kPaletteInvSize * 0.25;
float2 subsample = tintValues.rg * kSubsampleScale + kSubsampleOffset;
float4 uvsBase = float4(palU, palV, palU, kSurfacePalV);
float4 adjustedUV = subsample.xyxy + uvsBase;
colorValues   = tex2D(tintPaletteSampler, adjustedUV.xy) * (tintValues.b * 2);
surfaceValues = tex2D(tintPaletteSampler, adjustedUV.zw) * (tintValues.b * 2);
}
void BuildingPaletteSample(float palU, float palV, float4 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(kBilinearPaletteSample)
{
BuildingPaletteSampleBilerp(palU, palV, tintValues.xyz, colorValues, surfaceValues);
}
else
{
BuildingPaletteSamplePoint(palU, palV, tintValues.xyz, colorValues, surfaceValues);
}
}
static const float kAbandonedDesaturate = 0.750000;
static const float kAbandonedDarkening = 0.550000;
static const float kAbandonedAOExponent = 8.000000;
static const float kAbandonedSpecStrengthScale = 0.050000;
static const float kAbandonedSpecStrengthCap = 0.050000;
static const float kBuildingSpecOverdrive = 2.000000;
static const bool kInteriorEdgeBlock = (0) != 0;
static const float kBuildingInteriorMapSelfLightMax = 16.000000;

// ---- fragment body (spliced into the generated main()) ----
// sample textures
float4 facadeTintValues = tex2Dgrad(tintMapSampler,    relief_tc,  uv_ddx, uv_ddy);
float4 normalMapBase    = tex2Dgrad(normalMapSampler,  baseUv,     uv_ddx, uv_ddy);
float4 normalMapTop     = tex2Dgrad(normalMapSampler,  relief_tc,  uv_ddx, uv_ddy);
float4 shaderMapBase    = tex2Dgrad(shaderMapSampler,  baseUv,     uv_ddx, uv_ddy);
float4 shaderMapTop     = tex2Dgrad(shaderMapSampler,  relief_tc,  uv_ddx, uv_ddy);
float4 interiorMap = tex2D(interiorMapSampler, interior_tc);
if(kInteriorEdgeBlock)
{
float4 testEdge = float4(ddx(interiorElem), ddy(interiorElem));
float  onEdge = saturate(dot(testEdge, testEdge));
interiorMap.a = lerp(interiorMap.a, 0, onEdge);
}
facadeTintValues.a = (outsideTile > 0) ? 0 : facadeTintValues.a;
// Is normal lerp good enough?  Should renormalize?
float4 normalMapSampled = lerp(normalMapBase, normalMapTop, facadeTintValues.a);
float4 shaderMapSampled = lerp(shaderMapBase, shaderMapTop, facadeTintValues.a);
// tint
float4 tintBase;
float4 specBase;
BuildingPaletteSample(palU, buildingVariation, float4(baseTintValues.rgb, 0), tintBase, specBase);
float4 tintTop;
float4 specTop;
BuildingPaletteSample(palU2, buildingVariation, float4(facadeTintValues.rgb, 0), tintTop, specTop);
float4 tintResult = lerp(tintBase, tintTop, facadeTintValues.a);
float4 specResult = lerp(specBase, specTop, facadeTintValues.a);
// unpack
float3 normalMap = normalMapSampled.rgb;
float artistAO = normalMapSampled.a;
float artistOpacity = shaderMapSampled.a;
float artistSpecExponent = tintResult.a;
float artistReflectance = specResult.a;
// using interiorThresholds.z is a hack to turn the emissive off for unpowered buildings;
// powered buildings always have .z = 1, unpowered/abandoned buildings have .z = 0.
float artistEmissive = specResult.x * specResult.x * interiorThresholds.z;
float3 tintColor = tintResult.rgb;
// sh lighting
specStrength = shaderMapSampled.b*kBuildingSpecOverdrive;
specE = (artistSpecExponent*artistSpecExponent*artistSpecExponent) * 2048.0+1.0; // exponent comes from region palette
gloss = saturate(artistSpecExponent * specStrength);  // let's set the gloss to the un-modified spec exponent value
float3 bumpNormal = GetDeferredNormal(screenUV);
//bumpNormal.z += (artistSpecExponent*(abs(worldViewDirection.z)));
//bumpNormal = normalize(bumpNormal);
float3 bentViewDirection = worldViewDirection.xyz;
bentViewDirection.z += 2*saturate(-bentViewDirection.z)*(1-saturate(bumpNormal.z));
bentViewDirection = normalize(bentViewDirection);
if(isAbandoned)
{
specStrength *= kAbandonedSpecStrengthScale;
specStrength = min(specStrength, kAbandonedSpecStrengthCap);
artistAO = pow(artistAO, kAbandonedAOExponent);
float greyAmount = dot(tintColor, float3(.3, .59, .11));
tintColor = lerp(tintColor, make_float3(greyAmount), kAbandonedDesaturate) * (1 - kAbandonedDarkening);
}
// get lighting values
// TODO fix the view vector
float3 spec = float3(0, 0, 0);
SceneLighting(screenUV, bumpNormal, bentViewDirection, gloss, artistReflectance, specE, specStrength, shColorDiff, shColorSpec, spec);
// apply ao
float3 exteriorColor = tintColor * (shColorDiff + artistEmissive*256 + shColorSpec) * artistAO;
float3 interiorColor = interiorMap.rgb * (shColorDiff + interiorMap.aaa * kBuildingInteriorMapSelfLightMax + shColorSpec);
// combine colors
float3 finalColor = lerp(interiorColor, exteriorColor, artistOpacity);
finalColor += spec;
// output
Current.color.rgb = finalColor;
