// Shader fragment  [VS slot 252]  regionCityBuildingsImpostorWorldSpaceInstancedVS

// ---- uniform parameters ----
uniform float4x3 unitImpostorInstances[8];   // reg-meta 02ca02ca0018000000000008

// ---- fragment body (spliced into the generated main()) ----
float3 worldPos = mul( float4( Current.position.xyz, 1.0f ), unitImpostorInstances[ In.binormal.x ] );
// Output normal and tangent
float3 outputNormal  = mul( float4( Current.normal.xyz, 0.0f ), unitImpostorInstances[ In.binormal.x ] );
float3 outputTangent = mul( float4( Current.tangent.xyz, 0.0f ), unitImpostorInstances[ In.binormal.x ] );
float poweredState = In.binormal.y;
