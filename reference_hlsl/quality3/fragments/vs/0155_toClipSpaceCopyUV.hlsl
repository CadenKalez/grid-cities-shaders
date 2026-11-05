// Shader fragment  [VS slot 155]  toClipSpaceCopyUV

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = In.texcoord0;
float4 clipPosition = mul(Current.position, modelToClip);
Current.position = clipPosition;
