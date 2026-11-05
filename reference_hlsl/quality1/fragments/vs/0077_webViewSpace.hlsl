// Shader fragment  [VS slot 77]  webViewSpace

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 clipPosition = mul(Current.position, cameraToClip);
clipPosition.xy *= float2(2, -2);
Current.position = clipPosition;
