// Shader fragment  [VS slot 50]  perVertexFogging

// ---- uniform parameters ----
uniform float4 foggingCPU;   // reg-meta 022502250001000000004009
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4x4 viewTransform;   // reg-meta 025202520004000000000008

// ---- fragment body (spliced into the generated main()) ----
// fog strength
float fogDensity = foggingCPU.y;
float fogDistOffset = foggingCPU.x;
float term = foggingCPU.z;
float3 viewDirRaw = worldPosition.xyz - worldCameraPosition;
float dist = length(viewDirRaw);
float fogDist = max( dist - fogDistOffset, 0.0 );
float fogStrength = 1.0 - exp( fogDensity * fogDist );
fogStrength *= term;
// world space view
float3 viewDir =  viewDirRaw / dist;
float3 transDir = mul( -viewDir, viewTransform );
Current.texcoord<t0>.xyz = transDir;
Current.texcoord<t0>.w = fogStrength;
