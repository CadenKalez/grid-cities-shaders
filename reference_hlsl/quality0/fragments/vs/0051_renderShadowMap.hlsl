// Shader fragment  [VS slot 51]  renderShadowMap

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4 rangeAndStrength;   // reg-meta 022302230001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = (mul(Current.position, modelToCamera).z - rangeAndStrength.x) * rangeAndStrength.y;
Current.position = mul(Current.position, modelToClip);
