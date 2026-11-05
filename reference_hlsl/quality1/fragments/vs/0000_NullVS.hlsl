// Shader fragment  [VS slot 0]  NullVS

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- fragment body (spliced into the generated main()) ----
Current.position = mul(In.position, modelToClip);
