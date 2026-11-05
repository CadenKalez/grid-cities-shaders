// Shader fragment  [VS slot 270]  spotStencilBackFaceVF

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- fragment body (spliced into the generated main()) ----
float4 pos              = float4( modelPosition.xyz, 1 );
float4 hpos             = mul( pos, modelToClip );
Current.position        = hpos;
