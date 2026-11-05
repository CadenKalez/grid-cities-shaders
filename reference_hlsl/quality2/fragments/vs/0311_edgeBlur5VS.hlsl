// Shader fragment  [VS slot 311]  edgeBlur5VS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- fragment body (spliced into the generated main()) ----
float2 texOffset    = screenInfo.zw;
float4 uv;
uv = In.texcoord0.xxxy + texOffset.xxxy * float4(-2,-1,0,-2);
// horizontal rows
Current.texcoord<t0> = uv; uv.w += texOffset.y;
Current.texcoord<t1> = uv; uv.w += texOffset.y;
Current.texcoord<t2> = uv; uv.w += texOffset.y;
Current.texcoord<t3> = uv; uv.w += texOffset.y;
Current.texcoord<t4> = uv;
// 2 remaining elements in each row
uv = In.texcoord0.xxxy + texOffset.xxxy * float4(0,1,2,-2);
Current.texcoord<t5> = uv; uv.w += texOffset.y;
Current.texcoord<t6> = uv; uv.w += texOffset.y;
Current.texcoord<t7> = uv; uv.w += texOffset.y;
Current.color        = uv; uv.w += texOffset.y;
Current.color1       = uv;
