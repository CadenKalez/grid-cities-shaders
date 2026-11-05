// Shader fragment  [PS slot 1]  NullPS

// ---- uniform parameters ----
uniform float pulse;   // reg-meta 0028002800010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
Current.color = float4(1, 1 - pulse, 0, 1);
