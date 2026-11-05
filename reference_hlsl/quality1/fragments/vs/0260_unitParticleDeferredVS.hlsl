// Shader fragment  [VS slot 260]  unitParticleDeferredVS

// ---- uniform parameters ----
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
// Distance from view point relative to far clip.
Current.texcoord<t0>.x = cameraAlignedClipPos.w * nearFar.w;
// Calculate per-pixel depth offset
// That is, from [0..1] perpixel depth -> distance in camera space relative to far clip)
Current.texcoord<t0>.y = cardDepth.y * nearFar.w;
