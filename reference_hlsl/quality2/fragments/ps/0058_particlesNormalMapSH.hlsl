// Shader fragment  [PS slot 58]  particlesNormalMapSH

// ---- uniform parameters ----
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4 shCoeffs[4];   // reg-meta 021a02190004000000000008
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

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
float4 texColor = tex2D(Sampler0, In.texcoord0);
// compute normal map
float4 texNMap = tex2D(Sampler1, In.texcoord0);
float3 normal = 2 * texNMap.rgb - 1;
normal.z = -normal.z;   // flip z to point towards camera
normal = mul(normal, cameraToWorld);
float3 shDiff, shSpec;
SHDiffSpec4(normal, shDiff, shSpec, false);
Current.color.rgb *= shDiff;
