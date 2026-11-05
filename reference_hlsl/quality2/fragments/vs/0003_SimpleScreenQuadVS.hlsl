// Shader fragment  [VS slot 3]  SimpleScreenQuadVS

// ---- fragment body (spliced into the generated main()) ----
Current.position = float4(In.position.xy,0,1);
Current.texcoord<t0> = In.texcoord0.xy;
Current.color = In.color;
