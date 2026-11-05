// Shader fragment  [VS slot 53]  renderShadowMapAlphaMask

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4 rangeAndStrength;   // reg-meta 022302230001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.color = float4(0.f,0.f,0.f,0.f);
Current.texcoord<t0>.xyz = In.texcoord0.xyz;
Current.texcoord<t0>.w = (mul(Current.position, modelToCamera).z - rangeAndStrength.x) * rangeAndStrength.y;
Current.position = mul(Current.position, modelToClip);
