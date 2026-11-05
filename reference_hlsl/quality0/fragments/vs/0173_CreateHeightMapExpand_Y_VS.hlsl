// Shader fragment  [VS slot 173]  CreateHeightMapExpand_Y_VS

// ---- uniform parameters ----
uniform float4 samplerInfo0;   // reg-meta 025e025e0001000000400000

// ---- fragment body (spliced into the generated main()) ----
float2 texelSize        = samplerInfo0.zw;
Current.position        = float4( In.position.xy, 0, 1 );
Current.texcoord<t0>    = float4( In.texcoord0.xy, texelSize );
Current.texcoord<t1>    = In.texcoord0.xyxy + float4( 0, 1, 0, 2 ) * texelSize.xyxy;
Current.texcoord<t2>    = In.texcoord0.xyxy - float4( 0, 1, 0, 2 ) * texelSize.xyxy;
Current.texcoord<t3>    = In.texcoord0.xyxy + float4( 0,-3, 0, 3 ) * texelSize.xyxy;
