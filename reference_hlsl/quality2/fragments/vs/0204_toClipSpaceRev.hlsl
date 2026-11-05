// Shader fragment  [VS slot 204]  toClipSpaceRev

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001

// ---- fragment body (spliced into the generated main()) ----
float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
float4 clipPosition = mul(Current.position, modelToClip);
Current.position = clipPosition;
Current.position.y = -clipPosition.y;
