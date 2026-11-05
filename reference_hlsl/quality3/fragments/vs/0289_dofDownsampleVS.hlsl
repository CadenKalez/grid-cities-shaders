// Shader fragment  [VS slot 289]  dofDownsampleVS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000

// ---- fragment body (spliced into the generated main()) ----
//Current.position = mul( float4(position,1), worldToClip );
Current.texcoord<t0>.xy = In.texcoord0.xy + float2( -1.0, -1.0 ) * screenInfo.zw;
Current.texcoord<t0>.zw = In.texcoord0.xy + float2( +1.0, -1.0 ) * screenInfo.zw;
Current.texcoord<t1>.xy = In.texcoord0.xy + float2( -1.5, -1.5 ) * screenInfo.zw;
Current.texcoord<t1>.zw = In.texcoord0.xy + float2( -0.5, -1.5 ) * screenInfo.zw;
Current.texcoord<t2>.xy = In.texcoord0.xy + float2( +0.5, -1.5 ) * screenInfo.zw;
Current.texcoord<t2>.zw = In.texcoord0.xy + float2( +1.5, -1.5 ) * screenInfo.zw;
