// Shader fragment  [VS slot 309]  edgeDetectVS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- fragment body (spliced into the generated main()) ----
float2 texOffset    = screenInfo.zw;
Current.texcoord<t0> = In.texcoord0.xxxy + texOffset.xxxx * float4(-1,0,1,0); // horiz offsets
Current.texcoord<t1> = In.texcoord0.yyyx + texOffset.yyyy * float4(-1,0,1,0); // vert offsets
