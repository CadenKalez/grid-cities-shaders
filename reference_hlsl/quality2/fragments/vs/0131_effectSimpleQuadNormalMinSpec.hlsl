// Shader fragment  [VS slot 131]  effectSimpleQuadNormalMinSpec

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
float3 normal = normalize(-worldCameraDirection.xyz);
