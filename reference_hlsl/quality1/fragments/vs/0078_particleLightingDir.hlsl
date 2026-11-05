// Shader fragment  [VS slot 78]  particleLightingDir

// ---- uniform parameters ----
uniform float4 ambient;   // reg-meta 002300230001000000000020
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[4];   // reg-meta 021402140008000000003fc0

// ---- fragment body (spliced into the generated main()) ----
Current.color.rgb *= (ambient.rgb + dirLightsWorld[0].mColor.rgb);
