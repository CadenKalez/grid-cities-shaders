// Shader fragment  [PS slot 40]  volumeInfoFromDepth

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float3 farVolPoint = In.texcoord<t0>.xyz / In.texcoord<t0>.w;  // undo perspective correction
float3 volumeCameraPosition = In.texcoord<t1>.xyz;
float3 volumeUVW = volumeCameraPosition + farVolPoint * depth;
