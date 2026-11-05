// Shader fragment  [VS slot 82]  particleDepth

// ---- uniform parameters ----
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0>.x = clipPosition.w * nearFar.w;
