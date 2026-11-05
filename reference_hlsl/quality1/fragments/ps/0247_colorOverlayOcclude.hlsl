// Shader fragment  [PS slot 247]  colorOverlayOcclude

// ---- uniform parameters ----
uniform float4 customParams[4];   // reg-meta 020602060004000000000008

// ---- fragment body (spliced into the generated main()) ----
float4 color = customParams[0];
float occlusionOpacity = customParams[1].y;
Current.color = float4(color.rgb * color.a * occlusionOpacity, color.a * occlusionOpacity);
