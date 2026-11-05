// Shader fragment  [VS slot 253]  regionCityBuildingsImpostorWorldSpaceVS

// ---- uniform parameters ----
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform float4 customClipPlane;   // reg-meta 02c502c50001000000000008

// ---- fragment body (spliced into the generated main()) ----
float3 worldPos = mul( float4( Current.position.xyz, 1.0f ), modelToWorld );
// Output normal and tangent
float3 outputNormal  = mul( float4( Current.normal.xyz, 0.0f ), modelToWorld );
float3 outputTangent = mul( float4( Current.tangent.xyz, 0.0f ), modelToWorld );
float poweredState = customClipPlane.w;
