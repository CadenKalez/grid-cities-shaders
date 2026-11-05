// Shader fragment  [VS slot 58]  outputDepthVS

// ---- uniform parameters ----
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
Current.color = make_float4(clipPosition.w * nearFar.w * 255.0f);
