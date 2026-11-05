// Shader fragment  [PS slot 25]  tint

// ---- uniform parameters ----
uniform float4 tintParams;   // reg-meta 020c020c0001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.color *= tintParams;
