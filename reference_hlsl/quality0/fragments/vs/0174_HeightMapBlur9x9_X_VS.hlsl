// Shader fragment  [VS slot 174]  HeightMapBlur9x9_X_VS

// ---- uniform parameters ----
uniform float4 samplerInfo0;   // reg-meta 025e025e0001000000400000

// ---- fragment body (spliced into the generated main()) ----
float2 uv               = In.texcoord0.xy;
float2 texelSize        = samplerInfo0.zw;
Current.position        = float4( In.position.xy, 0, 1 );
Current.texcoord<t0>    = float4( uv, texelSize );
Current.texcoord<t1>    = In.texcoord0.xxxy + float4( 1.203511, 3.039779, 0, 0 ) * texelSize.xxxy;
Current.texcoord<t2>    = In.texcoord0.xxxy - float4( 1.203511, 3.039779, 0, 0 ) * texelSize.xxxy;
