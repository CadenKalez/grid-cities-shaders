// Shader fragment  [PS slot 374]  simParticleLightPS

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 samplerInfo0;   // reg-meta 025e025e0001000000400000
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
sampler sourceTex          : register(s0);
sampler offscreenNormalTex : register(s1);
sampler bodyPaletteTex     : register(s2);
sampler clothesPaletteTex  : register(s3);
static const bool kCheapSims = true;
static const bool kAllowMip = false;
static const bool kReallyExpensive = false;
void swap(inout float4 a, inout float4 b)
{
float4 temp = a;
a = b;
b = temp;
}
void merge(inout float4 a, inout float4 b)
{
a.x = (a.x * a.z + b.x * b.z) / (a.z + b.z);
a.z += b.z;
b.z = 0;
}
void FindPalEntry(float2 uv, out float palV, out float amount, out float alpha, out float4 debug)
{
const float2 kTexSize = samplerInfo0.xy;
const float2 kInvTexSize = samplerInfo0.zw;
if(kCheapSims

)
{
float4 tex;
if(kAllowMip)
tex = tex2D(sourceTex, uv);
else
tex = tex2Dlod(sourceTex, float4(uv, 0, 0));
amount = tex.r;
palV = tex.g;
alpha = tex.a;
debug = float4(0, 0, 0, 0);
return;
}
uv -= 0.5 * kInvTexSize;
float2 mid = fmod(uv, kInvTexSize);
float2 base = uv - mid;
float4 coords = float4(base, base+kInvTexSize);
float4 weightInfo = float4(mid, kInvTexSize - mid);
float4 weightX = float4(weightInfo.xxzz) * kTexSize.x;
float4 weightY = float4(weightInfo.ywyw) * kTexSize.y;
float4 weights = weightX * weightY;
float4 texBB, texBN, texNB, texNN;
if(kAllowMip)
{
texBB = tex2D(sourceTex, coords.xy);
texBN = tex2D(sourceTex, coords.xw);
texNB = tex2D(sourceTex, coords.zy);
texNN = tex2D(sourceTex, coords.zw);
}
else
{
texBB = tex2Dlod(sourceTex, float4(coords.xy, 0, 0));
texBN = tex2Dlod(sourceTex, float4(coords.xw, 0, 0));
texNB = tex2Dlod(sourceTex, float4(coords.zy, 0, 0));
texNN = tex2Dlod(sourceTex, float4(coords.zw, 0, 0));
}
float4 alphas = float4(texNN.a, texNB.a, texBN.a, texBB.a);
float4 pals   = float4(texNN.g, texNB.g, texBN.g, texBB.g);
float4 amts   = float4(texNN.r, texNB.r, texBN.r, texBB.r);
alpha = dot(alphas, weights);
weights = saturate(weights - (1 - alphas));
 float4 cmp1 = weights.xyxy > weights.zwzw ? float4(weights.xy, pals.xy) : float4(weights.zw, pals.zw);

float2 cmp2 = cmp1.x > cmp1.y ? cmp1.xz : cmp1.yw;
float weight = cmp2.x;
float p = cmp2.y;
weights = saturate(weights - (abs(pals - p) * 1024));
weights /= dot(float4(1, 1, 1, 1),weights);
debug = weights;
palV = p;
amount = dot(amts, weights);
}

// ---- fragment body (spliced into the generated main()) ----
float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
float bodyPalU = In.color.x;
float clothesPalU = In.color.y;
float2 uv = In.texcoord<t0>.xy;
float2 quadCorner = In.texcoord<t0>.zw;
float3 shColorDiff = In.texcoord<t1>.xyz;
float3 shColorSpec = In.texcoord<t2>.xyz;
float4 normalMapSample = tex2D(offscreenNormalTex, uv);
normalMapSample.rgb /= normalMapSample.a;
float4 normalDepth = ImpostorUnpackNormalDepth(normalMapSample);
float palV;
float aoFactor;
float alpha;
float4 debug;
FindPalEntry(uv, palV, aoFactor, alpha, debug);
if(kCheapSims

)
{
clip(normalMapSample.a - 0.7);
// force pixels that are drawn in deferred pass to be fully opaque
alpha = saturate( normalMapSample.a / 0.9);
}
else
{
clip(alpha - 0.3);
// force pixels that are drawn in deferred pass to be fully opaque
alpha = normalMapSample.a < 0.9 ? alpha : 1;
}
float4 bodyColor = tex2D(bodyPaletteTex, float2(bodyPalU, palV));
float4 clothesColor = tex2D(clothesPaletteTex, float2(clothesPalU, palV));
float3 tintColor = lerp(bodyColor.rgb, clothesColor.rgb, clothesColor.a);
// TODO tune these values and/or get per-pixel from sim material
gloss = 0.04;
specE = 8;
specStrength = 1;
// get lighting values
float3 spec = float3(0, 0, 0);
SceneLighting(screenUV, normalDepth.xyz, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
// light combine
Current.color.rgb = (tintColor * (shColorDiff + shColorSpec) + spec) * aoFactor;
Current.color.a = normalMapSample.a < 0.9 ? alpha : 1;
