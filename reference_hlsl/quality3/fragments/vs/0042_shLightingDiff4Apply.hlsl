// Shader fragment  [VS slot 42]  shLightingDiff4Apply

// ---- uniform parameters ----
uniform float4 shCoeffs[4];   // reg-meta 021a02190004000000000008

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

// ---- fragment body (spliced into the generated main()) ----
float3 normal = worldNormal;
float3 x0 = normal;
float3 shColorDiff = shCoeffs[0];
float3 shColor;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
Current.color.rgb *= shColorDiff;
