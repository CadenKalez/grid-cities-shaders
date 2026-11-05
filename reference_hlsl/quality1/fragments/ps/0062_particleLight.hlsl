// Shader fragment  [PS slot 62]  particleLight

// ---- uniform parameters ----
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
Current.color.rgb *= 1 - abs(worldDelta);
