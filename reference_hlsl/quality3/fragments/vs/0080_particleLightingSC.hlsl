// Shader fragment  [VS slot 80]  particleLightingSC

// ---- uniform parameters ----
uniform float4 shCoeffs[4];   // reg-meta 021a02190004000000000008
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000

// ---- declarations / helper functions ----
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

// ---- fragment body (spliced into the generated main()) ----
float3 normal = -worldCameraDirection.xyz;
float3 shDiff, shSpec;
SHDiffSpec4(normal, shDiff, shSpec, false); // normal is facing camera
float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
shDiff += sunMod * sunSky.mSunColor.rgb * 0.2;
Current.color.rgb *= shDiff;
