// Shader fragment  [VS slot 249]  simImpostorCameraDirection

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform struct { float4 projScale; float4 projOffset; float4 scale[8]; float4 offset[8]; float4x4 transform[8];} scImpostorAtlasPosition;   // reg-meta 02a202a20032000000000008

// ---- fragment body (spliced into the generated main()) ----
// rotate world camera back into model direction
float4 localCameraDirection = worldCameraDirection;
localCameraDirection.xyz = mul(make_float3x3(scImpostorAtlasPosition.transform[angle]), localCameraDirection.xyz);
