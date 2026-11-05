// Material shader: networkRoadBasicSH
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 modelToWorld;
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;
uniform float4 shCoeffs[9];
uniform float4 worldCameraDirection;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
const static float kSH_A1 = 2.0 / 3.0;
const static float kSH_A2 = 1.0 / 4.0;
const static float kSH_A3 = 0;
const static float kSH_A4 = -1.0 / 24.0;
const static float kDefaultGloss = 0.00;
const static float kGlossyMax    = 1.0; // threshold at which glossy maxes out
const static float kCelOutlineThreshold        = 0.25;
const static float kCelOutlineThresholdRange   = 0.075;
const static float kCelStrength                = 0.3;
const static float kSpecExponentMaxValue = 60.0;
const static bool kSaveInstructions = false;
void SHLighting
(
float3      normal,
float3      viewVector,
out float3  shColorDiff,
out float3  shColorSpec,
bool        translucency
)
{
float3 shColor;
float3 x0 = normal;
float3 x1 = x0 * x0;
float3 x2 = x0 * x0.yzx;
shColorDiff = shCoeffs[0].xyz;
shColorSpec = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
shColor  = shCoeffs[4].xyz  * x2.x;  // x * y
shColor += shCoeffs[5].xyz  * x2.y;  // y * z
shColor += shCoeffs[6].xyz  * (3 * x1.z - 1);
shColor += shCoeffs[7].xyz  * x2.z;  // z * x
shColor += shCoeffs[8].xyz  * (x1.x - x1.y);
shColor *= kSH_A2;
shColorDiff += shColor;
float3 reflectV;
if (translucency)
reflectV = -normal;
else
reflectV = reflect(viewVector, normal);
x0 = reflectV;
x1 = x0 * x0;
x2 = x0 * x0.yzx;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor += shCoeffs[4].xyz  * x2.x;  // x * y
shColor += shCoeffs[5].xyz  * x2.y;  // y * z
shColor += shCoeffs[6].xyz  * (3 * x1.z - 1);
shColor += shCoeffs[7].xyz  * x2.z;  // z * x
shColor += shCoeffs[8].xyz  * (x1.x - x1.y);
shColorSpec += shColor;
}
void SHDiffSpec9
(
float3      normal,
out float3  shColorDiff,
out float3  shColorSpec
)
{
SHLighting(normal, worldCameraDirection.xyz, shColorDiff, shColorSpec, false);
}

void main_vertex()
{
    // --- fragment: worldSpaceNormalTangent   (cond 0000000000000000000000000000000000000000000000ff)
    float3 worldNormal  = mul(Current.normal.xyz,  make_float3x3(modelToWorld));
    float3 worldTangent = mul(Current.tangent.xyz, make_float3x3(modelToWorld));
    worldNormal  = normalize(worldNormal);
    worldTangent = normalize(worldTangent);
    float3 worldBinormal = cross(worldTangent, worldNormal);
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: networkRoadBasicDefaultMinSpecVS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 shDiffuse;
    float3 shSpec;
    SHDiffSpec9(worldNormal.xyz, shDiffuse, shSpec);
    //direct lighting from sun
    float sunMod = saturate(dot(sunSky.mSunDir.xyz, worldNormal));
    shDiffuse += sunMod * sunSky.mSunColor.rgb;
    Current.texcoord<t0>.xyz = float3( In.texcoord0.xy, 0.0f );
    Current.texcoord<t1>.xyz = In.texcoord1.xyz;
    Current.texcoord<t2>.xyz = worldPosition.xyz;
    Current.texcoord<t3>.xyz = worldTangent;
    Current.texcoord<t4>.xyz = worldNormal;
    Current.texcoord<t5>.xyz = shDiffuse;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
sampler2D diffuseSampler        : register(s0);
sampler2D normalMapSampler      : register(s1);
sampler2D specSampler           : register(s2);
sampler2D noiseMaskSampler      : register(s3);
uniform float4 materialColor;

void main_pixel()
{
    // --- fragment: networkRoadBasicMaterialSetupMinSpec   (cond 0000000000000000000000000000000000000000000000ff)
    float2 baseUV        = In.texcoord<t0>.xy;
    float3 tileUV        = In.texcoord<t1>.xyz;
    float3 worldPosition = In.texcoord<t2>.xyz;
    float3 worldTangent  = In.texcoord<t3>.xyz;
    float3 shColorDiff   =  In.texcoord<t5>.xyz;
    // --- fragment: networkRoadBasicBaseColor   (cond 0000000000000000000000000000000000000000000000ff)
    float4 v4Diffuse = tex2D( diffuseSampler, baseUV );
    float4 v4NoiseMask = tex2D( noiseMaskSampler, float2(tileUV.x, tileUV.y/96.0) );
    clip(v4Diffuse.a - 0.75); 
    float noiseAlpha = v4NoiseMask.a * saturate(saturate(tileUV.z / 48.0f) * (abs(frac(worldPosition.x/73.0)-0.5) * abs(frac(worldPosition.y/87.0)-0.5) * 4 + 0.65));
    Current.color.rgb = lerp(v4Diffuse.rgb,v4NoiseMask.rgb,noiseAlpha) * materialColor.rgb;
    Current.color.w = materialColor.a;
    // --- fragment: networkRoadLightingMinSpecPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb*=shColorDiff;
}
