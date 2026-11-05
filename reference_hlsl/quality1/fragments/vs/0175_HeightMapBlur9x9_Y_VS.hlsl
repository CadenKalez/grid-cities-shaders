// Shader fragment  [VS slot 175]  HeightMapBlur9x9_Y_VS

// ---- uniform parameters ----
uniform float4 samplerInfo0;   // reg-meta 025e025e0001000000400000

// ---- fragment body (spliced into the generated main()) ----
float2 uv               = In.texcoord0.xy;
float2 texelSize        = samplerInfo0.zw;
Current.position        = float4( In.position.xy, 0, 1 );
Current.texcoord<t0>    = float4( uv, texelSize );
Current.texcoord<t1>    = In.texcoord0.yyyx + float4( 1.203511, 3.039779, 0, 0 ) * texelSize.yyyx;
Current.texcoord<t2>    = In.texcoord0.yyyx - float4( 1.203511, 3.039779, 0, 0 ) * texelSize.yyyx;
