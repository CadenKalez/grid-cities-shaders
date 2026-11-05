// Shader fragment  [VS slot 93]  effectSetupVF

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float age = modelPosition.w;
float4 color = In.color;
float3 cameraPos = worldCameraPosition.xyz;
float3 toCamera = cameraPos - modelPosition.xyz;
float cameraDist = length( toCamera );
float3 toCamNormal = toCamera / cameraDist;
