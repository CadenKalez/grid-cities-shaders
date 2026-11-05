// Shader fragment  [VS slot 149]  applyTerrainAOToWorldQuadVF

// ---- uniform parameters ----
uniform float4x4 clipToCamera;   // reg-meta 022902290004000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 clipCoord = float4(In.position.xy, 1, 1);
float4 toFarClip = mul(clipCoord, clipToCamera);
Current.position = In.position;
Current.texcoord<t0> = float4(In.texcoord<t0>.xy, 0,0);
Current.texcoord<t1> = toFarClip / toFarClip.w;
