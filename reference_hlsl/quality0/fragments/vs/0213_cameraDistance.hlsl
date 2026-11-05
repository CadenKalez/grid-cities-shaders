// Shader fragment  [VS slot 213]  cameraDistance

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float3 vertexToCamera = modelPosition.xyz - worldCameraPosition.xyz;
Current.texcoord<t0> = sqrt(dot(vertexToCamera, vertexToCamera));
