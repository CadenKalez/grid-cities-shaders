// Shader fragment  [VS slot 32]  copyAmbientColor

// ---- uniform parameters ----
uniform float4 ambient;   // reg-meta 002300230001000000000020

// ---- fragment body (spliced into the generated main()) ----
Current.color = ambient;
