// Material shader: particlesLit
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (11 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 materialColor;
uniform float4 shCoeffs[4];
uniform float4 worldCameraDirection;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform float4 worldCameraDirection;
uniform float4x3 cameraToWorld;
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
void SHDiffSpec4
(
float3      normal,
out float3  shColorDiff,
out float3  shColorSpec,
bool        translucency
)
{
float3 shColor;
float3 x0 = normal;
shColorDiff = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
float3 reflectV;
if (translucency)
reflectV = -normal;
else
reflectV = reflect(worldCameraDirection.xyz, normal);
x0 = reflectV;
shColorSpec = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColorSpec += shColor;
}
uniform float4 shCoeffs[4];
uniform float4 worldCameraDirection;
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
void SHDiffSpec4
(
float3      normal,
out float3  shColorDiff,
out float3  shColorSpec,
bool        translucency
)
{
float3 shColor;
float3 x0 = normal;
shColorDiff = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
float3 reflectV;
if (translucency)
reflectV = -normal;
else
reflectV = reflect(worldCameraDirection.xyz, normal);
x0 = reflectV;
shColorSpec = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColorSpec += shColor;
}
uniform float4 ambient;
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[4];
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;
uniform float4 foggingCPU;
uniform float4 worldCameraPosition;
uniform float4x4 viewTransform;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: copyVertexColor   (cond 0000000000000000000008000000000000000200000002ff)
    // --- fragment: whiteVertexColor   (cond 0000000000000000000000000000000000000200000002ff)
    Current.color = float4(1, 1, 1, 1);
    // --- fragment: applyMaterialColor   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= materialColor;
    // --- fragment: copyUV0   (cond 0a00000000000000000040000000000000000000000004ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: particleLightingSC   (cond 01028b0000000000000000000000000000000800000008ff)
    float3 normal = -worldCameraDirection.xyz;
    float3 shDiff, shSpec;
    SHDiffSpec4(normal, shDiff, shSpec, false); // normal is facing camera
    float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
    shDiff += sunMod * sunSky.mSunColor.rgb * 0.2;
    Current.color.rgb *= shDiff;
    // --- fragment: particleLightingSH   (cond 0102190000000000000000000000000000000800000008ff)
    float3 shDiff, shSpec;
    SHDiffSpec4(-worldCameraDirection.xyz, shDiff, shSpec, false); // normal is facing camera
    shDiff = shCoeffs[0].rgb + shCoeffs[2].rgb * kSH_A1;    // normal is facing upwards
    Current.color.rgb *= shDiff;
    // --- fragment: particleLightingDir   (cond 0000000000000000000000000000000000000800000008ff)
    Current.color.rgb *= (ambient.rgb + dirLightsWorld[0].mColor.rgb);
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: perVertexFogging   (cond 0102240000000000000000000000000000000000000000ff)
    // fog strength
    float fogDensity = foggingCPU.y;
    float fogDistOffset = foggingCPU.x;
    float term = foggingCPU.z;
    float3 viewDirRaw = worldPosition.xyz - worldCameraPosition;
    float dist = length(viewDirRaw);
    float fogDist = max( dist - fogDistOffset, 0.0 );
    float fogStrength = 1.0 - exp( fogDensity * fogDist );
    fogStrength *= term;
    // world space view
    float3 viewDir =  viewDirRaw / dist;
    float3 transDir = mul( -viewDir, viewTransform );
    Current.texcoord<t0>.xyz = transDir;
    Current.texcoord<t0>.w = fogStrength;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuseTextureSampler;
uniform float4 foggingCPU;
extern uniform sampler scatterMap : register(s9);

void main_pixel()
{
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: applyDiffuseTexture   (cond 0a00000000000000000040000000000000000000000004ff)
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
    Current.color *= diffuseTexture;
    // --- fragment: perVertexFogging   (cond 0102240000000000000000000000000000000000000000ff)
    float fogStrength = In.texcoord<t0>.w;
    float4 scatterColor  = texCUBE( scatterMap, In.texcoord<t0>.xyz );
    Current.color.rgb = lerp( Current.color.rgb, scatterColor.rgb, fogStrength ) + scatterColor.rgb * scatterColor.a * foggingCPU.w;
}
