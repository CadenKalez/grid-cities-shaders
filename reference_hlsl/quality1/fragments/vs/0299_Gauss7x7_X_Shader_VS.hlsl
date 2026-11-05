// Shader fragment  [VS slot 299]  Gauss7x7_X_Shader_VS

// ---- uniform parameters ----
uniform float4 textureSizes[4];   // reg-meta 022102210004000000400000

// ---- declarations / helper functions ----
static const bool kIsX = true;
static const float kPixWeight12 = 0.24197145 + 0.05399113 == 0 ? 1 : (0.24197145 + 0.05399113);
static const float kPixWeight34 = 0.00443186 + 0.00013383 == 0 ? 1 : (0.00443186 + 0.00013383);
static const float kPixWeight56 = 0 + 0 == 0 ? 1 : (0 + 0);
static const float kVertWeight12 = (0.24197145 + 0.05399113) == 0 ? 0 : ( (1 - 0.24197145 / kPixWeight12) + 1 );
static const float kVertWeight34 = (0.00443186 + 0.00013383) == 0 ? 0 : ( (1 - 0.00443186 / kPixWeight34) + 3 );
static const float kVertWeight56 = (0 + 0) == 0 ? 0 : ( (1 - 0 / kPixWeight56) + 5 );

// ---- fragment body (spliced into the generated main()) ----
float2 uv               = In.texcoord0.xy;
float2 texelSize        = textureSizes[0].zw;
Current.position        = float4( In.position.xy, 0, 1 );
Current.texcoord<t0>    = float4( uv, texelSize );
if (kIsX)
{
Current.texcoord<t1>    = In.texcoord0.xxxy + float4( kVertWeight12, kVertWeight34, kVertWeight56, 0 ) * texelSize.xxxy;
Current.texcoord<t2>    = In.texcoord0.xxxy - float4( kVertWeight12, kVertWeight34, kVertWeight56, 0 ) * texelSize.xxxy;
}
else
{
Current.texcoord<t1>    = In.texcoord0.yyyx + float4( kVertWeight12, kVertWeight34, kVertWeight56, 0 ) * texelSize.yyyx;
Current.texcoord<t2>    = In.texcoord0.yyyx - float4( kVertWeight12, kVertWeight34, kVertWeight56, 0 ) * texelSize.yyyx;
}
