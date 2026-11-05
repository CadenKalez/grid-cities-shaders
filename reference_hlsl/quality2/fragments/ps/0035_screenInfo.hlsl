// Shader fragment  [PS slot 35]  screenInfo

// ---- uniform parameters ----
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
