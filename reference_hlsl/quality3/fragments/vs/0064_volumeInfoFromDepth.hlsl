// Shader fragment  [VS slot 64]  volumeInfoFromDepth

// ---- uniform parameters ----
uniform struct { float4 origin; float4 invWidth; float4 tuning; } volumeInfo;   // reg-meta 02c002c00003000000000008
uniform float4x4 clipToModel;   // reg-meta 022702270004000000004001
uniform float4 modelCameraPosition;   // reg-meta 001e001e0001000000004001

// ---- fragment body (spliced into the generated main()) ----
// Volume-relative version of the same. We need to pass up the camera volume position too.
float3 volMin      = volumeInfo.origin.xyz;
float3 volInvScale = volumeInfo.invWidth.xyz;
float4 farVolPoint = mul(clipPosition.xyww, clipToModel);
farVolPoint /= farVolPoint.w;
farVolPoint.xyz -= modelCameraPosition.xyz;
farVolPoint.xyz *= volInvScale;
float3 volumeCameraPosition = (modelCameraPosition.xyz - volMin) * volInvScale;
Current.texcoord<t0> = farVolPoint * hw;
Current.texcoord<t1>.xyz = volumeCameraPosition;
Current.texcoord<t1>.w = 1;
