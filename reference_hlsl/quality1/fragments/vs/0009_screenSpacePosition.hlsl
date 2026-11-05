// Shader fragment  [VS slot 9]  screenSpacePosition

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.position.xy *= screenInfo.zw; //  * float2(-1, 2);
Current.position.xy -= float2(0.5, 0.5);
Current.position.xy *= float2(2, -2);
Current.position.zw = float2(0, 1);
