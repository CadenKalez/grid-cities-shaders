// Shader fragment  [VS slot 92]  volumeFire

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4x3 worldToPatch;   // reg-meta 023e02260003000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = In.texcoord0.xyz;
Current.texcoord<t1> = mul(modelPosition, worldToPatch);
