// Shader fragment  [VS slot 31]  applyMaterialColor

// ---- uniform parameters ----
uniform float4 materialColor;   // reg-meta 002200220001000000000010

// ---- fragment body (spliced into the generated main()) ----
Current.color *= materialColor;
