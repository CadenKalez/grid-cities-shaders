// Shader fragment  [PS slot 246]  colorOverlay

// ---- uniform parameters ----
uniform float4 customParams[4];   // reg-meta 020602060004000000000008

// ---- fragment body (spliced into the generated main()) ----
// Pre-multiplied alpha
Current.color = float4(customParams[0].rgb * customParams[0].a, customParams[0].a);
