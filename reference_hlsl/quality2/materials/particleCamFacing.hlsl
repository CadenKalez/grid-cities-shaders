// Material shader: particleCamFacing
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 cameraToClip;
uniform float4x3 modelToWorld;
uniform float4x3 worldToCamera;
uniform struct { float4 texXform; float4 worldSpaceCardData; float4 cameraSpaceCardData; float4x3 cameraTransform;} unitImpostorParticles[16];
static const float kZBiasFactor = -0.00001f;
static const float2 vtxInfo[ 4 ] =
{
float2( 0.0f, 0.0f ),
float2( 1.0f, 0.0f ),
float2( 1.0f, 1.0f ),
float2( 0.0f, 1.0f )
};

void main_vertex()
{
    // --- fragment: unitParticleTransformVS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 modelData = In.texcoord0.xy;
    float3 position  = modelPosition.xyz;
    position = mul( float4( position, 1.0f ), modelToWorld );
    // Get information for this corner of the quad.
    float2 quadCorner = vtxInfo[ modelData.x ];
    // Get model index.
    int cellIndex = modelData.y;
    float4 texXform            = unitImpostorParticles[ cellIndex ].texXform;
    float4 worldSpaceCardData  = unitImpostorParticles[ cellIndex ].worldSpaceCardData;
    float4 cameraSpaceCardData = unitImpostorParticles[ cellIndex ].cameraSpaceCardData;
    float3 cardDepth           = unitImpostorParticles[ cellIndex ].cameraTransform[ 3 ];
    // Offset in world space.
    float3 worldOffset = float3( worldSpaceCardData.xy + worldSpaceCardData.zw * quadCorner, 0.0f );
    // Rotate offset by camera view (which is the camera matrix in world space).
    worldOffset.xyz = mul( float4( worldOffset.xzy, 0.0f ), unitImpostorParticles[ cellIndex ].cameraTransform );
    // Get camera space position & offset to quad corner.
    float3 viewPos = mul( float4( position + worldOffset, 1.0f ), worldToCamera );
    // Get clip space position of quad corner.
    float4 clipPos = mul( float4( viewPos, 1.0f ), cameraToClip );
    // Z-bias.
    clipPos.z += clipPos.w * kZBiasFactor;
    // Get UV.
    float2 uv = texXform.xy + texXform.zw * quadCorner;
    Current.position       = clipPos;
    Current.texcoord<t0>   = float4( uv, quadCorner );
     Current.texcoord<t0>.y = 1.0f - Current.texcoord<t0>.y; 
    Current.texcoord<t1>   = modelPosition;
    // Offset in camera space.
    float3 camOffset            = float3( cameraSpaceCardData.xy + cameraSpaceCardData.zw * quadCorner, cardDepth.x );
    float3 cameraAlignedViewPos = mul( float4( position, 1.0f ), worldToCamera ) + camOffset;
    // Get clip space position of quad corner.
    float4 cameraAlignedClipPos = mul( float4( cameraAlignedViewPos, 1.0f ), cameraToClip );
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
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
sampler diffuseMap : register(s0);
sampler normalMap  : register(s1);
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
uniform float4 worldCameraDirection;
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
static const float3 kInteriorColor = float3( 1.0f, 0.94117647059f, 0.196078431372f );

void main_pixel()
{
    // --- fragment: deferredDiffuseDisabled   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: unitParticleSamplePS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = ( In.vpos.xy + float2( 0.5f, 0.5f ) ) * screenInfo.zw;
    float2 uv       = In.texcoord<t0>.xy;
    float4 diffuseMapSample = tex2D( diffuseMap, uv );
    // We render pixels with alpha >= 0.9 into the deferred map,
    // so compensate by making 0.9 be 'opaque'.
    diffuseMapSample.a = saturate( diffuseMapSample.a * ( 1.0f / 0.9f ) );
    float4 normalMapSample = tex2D( normalMap, uv );
    float4 normalDepth = ImpostorUnpackNormalDepth( normalMapSample );
    // --- fragment: unitParticleLightPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 shColorDiff = float3( 0.0f, 0.0f, 0.0f );
    float3 shColorSpec = float3( 0.0f, 0.0f, 0.0f );
    float3 position    = In.texcoord<t0>.xyz;
    float3 worldNormal = normalDepth.xyz;
    float3 tintColor   = diffuseMapSample.rgb;
    // TODO: tune these values and/or get per-pixel from sim material.
    float gloss        = 0.08f;
    float specE        = 3.0f;
    float specStrength = 0.2f;
    // Get lighting values.
    float3 spec = float3( 0.0f, 0.0f, 0.0f );
    SceneLighting( screenUV, worldNormal, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec );
    float3 finalColor;
    finalColor = tintColor * ( shColorDiff + shColorSpec ) + spec;
    finalColor = lerp( finalColor, kInteriorColor, normalMapSample.a );
    // light combine
    Current.color.rgb = finalColor;
    Current.color.a   = diffuseMapSample.a;
}
