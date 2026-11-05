// Shader fragment  [PS slot 2]  InvalidMaterialPS

// ---- uniform parameters ----
uniform float pulse;   // reg-meta 0028002800010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
Current.color = float4(pulse, 0, 0, 1);
