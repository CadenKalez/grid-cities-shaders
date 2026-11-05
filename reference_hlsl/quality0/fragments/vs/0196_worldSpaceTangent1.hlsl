// Shader fragment  [VS slot 196]  worldSpaceTangent1

// ---- uniform parameters ----
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001

// ---- fragment body (spliced into the generated main()) ----
float3 worldTangent1 = normalize( mul( Current.tangent1.xyz, make_float3x3( modelToWorld ) ) );
