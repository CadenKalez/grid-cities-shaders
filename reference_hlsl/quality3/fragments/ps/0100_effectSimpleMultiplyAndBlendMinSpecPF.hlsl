// Shader fragment  [PS slot 100]  effectSimpleMultiplyAndBlendMinSpecPF

// ---- uniform parameters ----
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float colorMultiply = customParams[0].z;
diffuse *= color;
diffuse.rgb *= colorMultiply;
