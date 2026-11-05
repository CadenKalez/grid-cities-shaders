// Shader fragment  [VS slot 86]  defaultQuadSetShaderVS

// ---- uniform parameters ----
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000

// ---- fragment body (spliced into the generated main()) ----
float2 uv = Current.texcoord0.xy;
// get camera space position & offset to quad corner
float3 cPos = mul(float4(Current.position.xyz, 1), worldToCamera);
cPos.xy += Current.normal.xy * Current.normal.w; 
// get clip space position of quad corner
float4 pPos = mul(float4(cPos, 1), cameraToClip);
Current.position = pPos;
