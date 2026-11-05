// Shader fragment  [VS slot 236]  instancedCamTransform

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 localCameraDirection;
localCameraDirection.xyz = mul(worldCameraDirection.xyz,float3x3(In.texcoord1.xyz,In.texcoord2.xyz,In.texcoord3.xyz));
localCameraDirection.w = worldCameraDirection.w;
