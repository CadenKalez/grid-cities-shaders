// Shader fragment  [PS slot 61]  softParticles

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
float e = dot(worldNormal, worldCameraDirection.xyz);
Current.color.a *= saturate(worldDelta + e * e);
