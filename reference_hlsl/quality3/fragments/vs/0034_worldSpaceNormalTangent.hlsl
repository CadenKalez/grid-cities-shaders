// Shader fragment  [VS slot 34]  worldSpaceNormalTangent

// ---- uniform parameters ----
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001

// ---- fragment body (spliced into the generated main()) ----
float3 worldNormal  = mul(Current.normal.xyz,  make_float3x3(modelToWorld));
float3 worldTangent = mul(Current.tangent.xyz, make_float3x3(modelToWorld));
worldNormal  = normalize(worldNormal);
worldTangent = normalize(worldTangent);
float3 worldBinormal = cross(worldTangent, worldNormal);
