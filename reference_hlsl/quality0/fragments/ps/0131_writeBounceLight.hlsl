// Shader fragment  [PS slot 131]  writeBounceLight

// ---- uniform parameters ----
uniform float4 tintParams;   // reg-meta 020c020c0001000000000008

// ---- fragment body (spliced into the generated main()) ----
float bounceFactor = Current.color.a;
float bc = 2 * volumeUVW.z - 1;
bounceFactor *= 0.7;
Current.color1.rgb = bounceFactor * tintParams.rgb;
Current.color1.a = 0;
