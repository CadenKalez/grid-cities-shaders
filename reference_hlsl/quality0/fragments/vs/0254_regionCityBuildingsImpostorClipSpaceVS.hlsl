// Shader fragment  [VS slot 254]  regionCityBuildingsImpostorClipSpaceVS

// ---- uniform parameters ----
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform struct { float4 projScale; float4 projOffset; float4 viewScale; float4 viewOffset; float4x3 cameraTransform;float4 cameraAlignedProjOffset; } unitImpostorProjs;   // reg-meta 02cb02cb0008000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.position.xyz = mul( float4( worldPos, 0.0f ), unitImpostorProjs.cameraTransform );
float3 cameraAlignedProjScale  = unitImpostorProjs.cameraTransform[3];
float3 cameraAlignedProjOffset = unitImpostorProjs.cameraAlignedProjOffset.xyz;
float3 cameraSpacePosition = mul( float4( worldPos, 0.0f ), worldToCamera );
cameraSpacePosition *= cameraAlignedProjScale;
cameraSpacePosition += cameraAlignedProjOffset;
// orthographic projection into bounding box space
Current.position.xyz *= unitImpostorProjs.projScale.xyz;
Current.position.xyz += unitImpostorProjs.projOffset.xyz;
// send position to pixel shader for clipping by texture boundary
float3 clipPosition = Current.position.xyz;
// move into texture atlas
Current.position.xyz *= unitImpostorProjs.viewScale.xyz;
Current.position.xyz += unitImpostorProjs.viewOffset.xyz;
float interiorLightTime = unitImpostorProjs.viewOffset.w;
