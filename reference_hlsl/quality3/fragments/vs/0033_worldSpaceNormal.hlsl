// Shader fragment  [VS slot 33]  worldSpaceNormal

// ---- uniform parameters ----
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001

// ---- fragment body (spliced into the generated main()) ----
float3 worldNormal  = mul(Current.normal.xyz, make_float3x3(modelToWorld));
worldNormal  = normalize(worldNormal);
