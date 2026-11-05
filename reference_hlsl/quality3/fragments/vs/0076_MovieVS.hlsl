// Shader fragment  [VS slot 76]  MovieVS

// ---- uniform parameters ----
uniform float4 materialColor;   // reg-meta 002200220001000000000010
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.position.xy *= screenInfo.zw;
Current.position.xy -= float2(0.5, 0.5);
Current.position.xy *= float2(2, -2);
Current.color = materialColor;
Current.texcoord0 = In.texcoord0.xy;
