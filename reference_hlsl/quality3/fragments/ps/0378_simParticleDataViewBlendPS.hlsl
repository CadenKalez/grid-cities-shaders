// Shader fragment  [PS slot 378]  simParticleDataViewBlendPS

// ---- uniform parameters ----
uniform float4 contourColor;   // reg-meta 02c702c70001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.color *= contourColor.a;
Current.color.a = contourColor.a;
