// Shader fragment  [VS slot 199]  vehicleSetupInteriorVS

// ---- uniform parameters ----
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000

// ---- fragment body (spliced into the generated main()) ----
// Calculate the bi-normal of tangent 1.
float3 worldBinormal1;
worldBinormal1 = cross( worldTangent1, worldNormal );
float3 viewTangent  = mul( float4( worldTangent1, 0.0f ), worldToCamera ).xyz;
float3 viewBinormal = mul( float4( worldBinormal1, 0.0f ), worldToCamera ).xyz;
float3 viewNormal   = mul( float4( worldNormal, 0.0f ) , worldToCamera ).xyz;
float3 viewPos      = mul( float4( worldPosition.xyz, 1.0f ), worldToCamera ).xyz;
float3x3 tangentSpace = float3x3( viewTangent, viewBinormal, viewNormal );
float3   eyeDir       = -mul( tangentSpace, viewPos );
