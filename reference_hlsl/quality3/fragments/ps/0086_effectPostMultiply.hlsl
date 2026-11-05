// Shader fragment  [PS slot 86]  effectPostMultiply

// ---- uniform parameters ----
uniform float4 customParams[1];   // reg-meta 020602060001000000000008

// ---- fragment body (spliced into the generated main()) ----
diffuse.rgb *= customParams[0].z;
