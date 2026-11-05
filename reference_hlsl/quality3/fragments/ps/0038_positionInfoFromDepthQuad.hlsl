// Shader fragment  [PS slot 38]  positionInfoFromDepthQuad

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
float3 farPoint  = In.texcoord<t0>.xyz;
float3 viewPosition  = worldCameraPosition.xyz;
float3 viewDirection = normalize(farPoint);
float3 worldDistance = make_float3(depth * nearFar.y);
float3 worldPosition = viewPosition + farPoint * depth;
