// Shader fragment  [VS slot 310]  edgeBlur3VS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- fragment body (spliced into the generated main()) ----
float2 texOffset    = screenInfo.zw;
float4 uv;
uv = In.texcoord0.xxxy + texOffset.xxxy * float4(-1,-0,1,-1);
// horizontal rows
Current.texcoord<t0> = uv; uv.w += texOffset.y;
Current.texcoord<t1> = uv; uv.w += texOffset.y;
Current.texcoord<t2> = uv;
