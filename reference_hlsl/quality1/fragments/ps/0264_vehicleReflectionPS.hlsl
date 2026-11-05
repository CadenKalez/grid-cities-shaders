// Shader fragment  [PS slot 264]  vehicleReflectionPS

// ---- declarations / helper functions ----
static const float reflectionIntensity = 0.15f;

// ---- fragment body (spliced into the generated main()) ----
float3 reflectColor  = texCUBE( reflectionSampler, reflectedView ).rgb;
finalColor = lerp( finalColor, reflectColor, specStrength * reflectionIntensity );
