// Shader fragment  [VS slot 287]  viewToClip

// ---- uniform parameters ----
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000

// ---- fragment body (spliced into the generated main()) ----
Current.position = mul(In.position, cameraToClip);
