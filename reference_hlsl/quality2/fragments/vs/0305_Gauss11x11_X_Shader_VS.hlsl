// Shader fragment  [VS slot 305]  Gauss11x11_X_Shader_VS

// ---- uniform parameters ----
uniform float4 textureSizes[4];   // reg-meta 022102210004000000400000

// ---- declarations / helper functions ----
static const bool kIsX = true;
static const float kPixWeight12 = 0.19994990 + 0.11652046 == 0 ? 1 : (0.19994990 + 0.11652046);
static const float kPixWeight34 = 0.04737368 + 0.01343774 == 0 ? 1 : (0.04737368 + 0.01343774);
static const float kPixWeight56 = 0.00265931 + 0.00036717 == 0 ? 1 : (0.00265931 + 0.00036717);
static const float kVertWeight12 = (0.19994990 + 0.11652046) == 0 ? 0 : ( (1 - 0.19994990 / kPixWeight12) + 1 );
static const float kVertWeight34 = (0.04737368 + 0.01343774) == 0 ? 0 : ( (1 - 0.04737368 / kPixWeight34) + 3 );
static const float kVertWeight56 = (0.00265931 + 0.00036717) == 0 ? 0 : ( (1 - 0.00265931 / kPixWeight56) + 5 );

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
