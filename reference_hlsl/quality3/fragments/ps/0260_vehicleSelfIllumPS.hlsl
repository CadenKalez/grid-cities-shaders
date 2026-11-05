// Shader fragment  [PS slot 260]  vehicleSelfIllumPS

// ---- declarations / helper functions ----
static const float3 kHeadlightColor = float3( 60.0f, 40.0f, 10.0f );
static const float3 kBrakeColor     = float3( 250.0f, 0.3f, 0.3f );
static const float3 kRunningColor   = float3( 1.75f, 0.25f, 0.25f );
static const float3 kEpsilon = float3( 0.05f, 0.05f, 0.05f );
static const float3 kZero    = float3( 0.0f, 0.0f, 0.0f );

// ---- fragment body (spliced into the generated main()) ----
// headlight, brakes, running
float3 inputSelfIllumMask = miscParams.yzw;
float3 emissiveMask = saturate( selfIllumMask.xyy * inputSelfIllumMask );
// If the emissive mask falls below the epsilon value then clamp it to 0.
// Otherwise the overbrightened color values expose these errors.
 emissiveMask = ( emissiveMask < kEpsilon ) ? kZero : emissiveMask;

float3 emissiveColorA = kHeadlightColor * emissiveMask.x;
float3 emissiveColorB = kBrakeColor     * emissiveMask.y;
float3 emissiveColorC = kRunningColor   * emissiveMask.z;
finalColor += ( emissiveColorA + emissiveColorB + emissiveColorC );
