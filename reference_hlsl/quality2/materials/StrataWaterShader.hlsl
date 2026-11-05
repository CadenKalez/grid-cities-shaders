// Material shader: StrataWaterShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mScaleAndBias1; float4 mScaleAndBias2; } terrainSurfaceInfoVS;
uniform float4x4 modelToClip;
sampler HeightMap : register(s0);       
sampler ThicknessMap : register(s1);
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: strataWaterVS   (cond 0000000000000000000000000000000000000000000000ff)
    {
    Current.texcoord0 = Current.position.xyxy / 1024;  
    Current.texcoord0 = 0.5 * (Current.texcoord<t0> + 1);
    Current.texcoord1 = float4( Current.normal.xyz, 0 );
    Current.texcoord2.w = 1;
    float2 uv1 = Current.position.xy;
    uv1 /= 2048.0;
    uv1 += 0.5;
    uv1 = saturate(uv1);
    float height = tex2Dlod(HeightMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048 - 1024;
    float thickness = tex2Dlod(ThicknessMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048;
    Current.texcoord2.w = thickness;  
    Current.position.z += height;
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.texcoord<t3>.xyzw = clipPosition;
    Current.texcoord2.xyz = Current.position.xyz;
    }
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;
uniform struct { float4 mColor; float4 mReflectionParams; float4 mSpecularNormal; float4 mSunDir; } waterStrataInfoPS;
uniform float4 worldCameraPosition;
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
extern uniform sampler ChoppyMap : register(s0);
extern uniform sampler NormalMap : register(s1);
extern uniform sampler ReflectionMap : register(s2);
extern uniform sampler RefractionMap : register(s3);
extern uniform sampler FoamTexture : register(s4);

void main_pixel()
{
    // --- fragment: strataWaterPS   (cond 0000000000000000000000000000000000000000000000ff)
    {
    clip(In.texcoord2.w-4.0);  
    float4 pos = float4(In.texcoord<t0>.xyz, 1);
    float waterLevel = waterStrataInfoPS.mReflectionParams.x;
    float reflectionScale = waterStrataInfoPS.mReflectionParams.y;   
    const float CHOPPY_MAP_TILING = 4.0;       
    const float NORMAL_MAP_TILING = 8.0;       
    float2 uv1 = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    uv1 *= CHOPPY_MAP_TILING;
    float2 uv2 = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    uv2 *= NORMAL_MAP_TILING;
    float3 origChoppy = tex2D(ChoppyMap, uv1).xyz;  
    float3 origNormal = tex2D(NormalMap, uv2).xyz * 2.0 - 1.0;  
    float3 choppy = waterStrataInfoPS.mSpecularNormal.z * origChoppy;
    float3 normal = waterStrataInfoPS.mSpecularNormal.w * origNormal;
    normal += choppy;
    normal = normalize(normal);
    float3 toCamera = worldCameraPosition - In.texcoord<t2>.xyz;
    float3 L = sunSky.mSunDir.xyz;  // dir to sun
    float3 V = normalize(toCamera);  
    const float fresnelScale = 20.0;
    float fresnelTerm = dot(V, normal);  
    fresnelTerm = pow(fresnelTerm, 4.0);
    fresnelTerm *= fresnelScale;
    fresnelTerm = saturate(fresnelTerm);
    float3 N = normal;  
    float waterDepth = In.texcoord<t2>.w;
    float angle = clamp(waterDepth / 5, 0, 3.14159 / 2.0);    
    float density = clamp(waterDepth / 30, 0, 3.14159 / 2.0);  
    float trans1 = sin(angle);    
    float trans2 = sin(density);  
    float3 shDiffuse;
    float3 shSpec;
    float3 RS = reflect(-V, N) * 1.0;
    float3 skyColor = SkyColor(sunSky, RS);
    float cosSunAngle = sunSky.mSunDir.w;
    float sunStrength = smoothstep(cosSunAngle - 0.00005, cosSunAngle + 0.00005, dot(RS, sunSky.mSunDir.xyz));
    shSpec = sunStrength * sunSky.mSunColor.xyz;
    shDiffuse = skyColor;
    const float4 deepColor = float4(0, 45, 65, 0)/255.0 * .5;
    float3 reflectedColor = shDiffuse;   
    reflectedColor = reflectedColor * 0.5 + (float3(0,72,106)/255.0) * 0.5;  
    float3 clipPos = In.texcoord<t3>.xyz / In.texcoord<t3>.w;
    float2 screenPos = clipPos.xy * 0.5 + 0.5;
    float2 screenUV = float2(screenPos.x, 1.0 - screenPos.y);
    float pixelDepth = In.texcoord<t2>.z * 0.001;   
    float3 refractedRay = refract(V, normalize(normal*float3(1,1,0.001)), 1.333);
    float2 refractionUV = screenUV + refractedRay.xy * waterDepth * 0.0005;  
    float4 refractionMapColor = tex2D(RefractionMap, refractionUV).rgba;
    refractionMapColor.rgb /= refractionMapColor.a;  
    float3 refractedColor = refractionMapColor.xyz;
    refractedColor = lerp(refractedColor, deepColor.xyz, trans2);
    float2 reflectionUV = float2(screenUV + normal.xy * waterDepth * 0.00075);  
    float4 reflectionMapColor = tex2D(ReflectionMap, reflectionUV).rgba;
    reflectionMapColor.rgb /= reflectionMapColor.a;  
    reflectedColor = any(reflectionMapColor.rgb) ? reflectionMapColor.rgb * 0.75 : reflectedColor;  
    fresnelTerm    = any(reflectionMapColor.rgb) ? fresnelTerm * 0.25            : fresnelTerm;     
    float3 combinedColor = lerp(reflectedColor, refractedColor, fresnelTerm);
    const float FOAM_MAP_TILING = 10.0;       
    float waveHeight = length(normal.xz) * 15.0;
    float2 uv3 = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    uv3 /= 2048.0 / FOAM_MAP_TILING;
    uv3 += 0.5;
    float3 foam1 = tex2D(FoamTexture, uv3).rgb;
    foam1 *= foam1;  
    float3 foam2 = foam1;
    foam2 *= foam2;
    float3 foam = foam1 + foam2;
    shDiffuse = combinedColor;  
    Current.color.rgba = float4(shDiffuse + shSpec, trans1);
    }
}
