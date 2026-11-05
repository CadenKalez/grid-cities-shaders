// Shader fragment  [VS slot 313]  motionBlurQuadVS

// ---- uniform parameters ----
uniform float4x4 clipToWorld;   // reg-meta 022802280004000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0>.xyz = In.texcoord<t0>.xyz;  
float2 coords = In.texcoord0.xy * 2.0 - 1.0;
coords.y = -coords.y;
float4 farPoint  = mul(float4(coords, 1, 1), clipToWorld);
Current.texcoord<t1> = farPoint.xyz / farPoint.w - worldCameraPosition.xyz;
