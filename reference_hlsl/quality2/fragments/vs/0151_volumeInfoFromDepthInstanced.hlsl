// Shader fragment  [VS slot 151]  volumeInfoFromDepthInstanced

// ---- uniform parameters ----
uniform struct { float4 origin; float4 invWidth; float4 tuning; } volumeInfo;   // reg-meta 02c002c00003000000000008
uniform float4x4 clipToWorld;   // reg-meta 022802280004000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
// Volume-relative version of the same. We need to pass up the camera volume position too.
// Note that we assume that w2m is orthonormal
float4x4 w2m;
w2m[0] = float4(m2w[0].xyz, 0.0f);
w2m[1] = float4(m2w[1].xyz, 0.0f);
w2m[2] = float4(m2w[2].xyz, 0.0f);
float3 m2w_trans = float3(m2w[0].w, m2w[1].w,m2w[2].w);
w2m[3] = float4( -mul(m2w_trans, make_float3x3(w2m)), 1.0f);
float4x4 c2m = mul(clipToWorld, w2m);
float4 mdlCamPos = mul(worldCameraPosition, w2m);
float3 volMin      = volumeInfo.origin.xyz;
float3 volInvScale = volumeInfo.invWidth.xyz;
float4 farVolPoint = mul(clipPosition.xyww, c2m);
farVolPoint /= farVolPoint.w;
farVolPoint.xyz -= mdlCamPos.xyz;
farVolPoint.xyz *= volInvScale;
float3 volumeCameraPosition = (mdlCamPos.xyz - volMin) * volInvScale;
Current.texcoord<t0> = farVolPoint * hw;
Current.texcoord<t1>.xyz = volumeCameraPosition;
Current.texcoord<t1>.w = 1;
Current.texcoord<t2> = w2m[0];
Current.texcoord<t3> = w2m[1];
Current.texcoord<t4> = w2m[2];
