// Shader fragment  [VS slot 68]  modelPosition

// ---- uniform parameters ----
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001

// ---- fragment body (spliced into the generated main()) ----
float3 modelPos = mul(float4(0,0,0,1), modelToWorld).xyz;
