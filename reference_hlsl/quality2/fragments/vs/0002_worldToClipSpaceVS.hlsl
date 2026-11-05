// Shader fragment  [VS slot 2]  worldToClipSpaceVS

// ---- uniform parameters ----
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000

// ---- fragment body (spliced into the generated main()) ----
Current.position = mul(float4(Current.position.xyz, 1), worldToClip);
