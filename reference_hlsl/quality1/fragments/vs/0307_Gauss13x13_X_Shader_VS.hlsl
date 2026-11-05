// Shader fragment  [VS slot 307]  Gauss13x13_X_Shader_VS

// ---- uniform parameters ----
uniform float4 textureSizes[4];   // reg-meta 022102210004000000400000

// ---- declarations / helper functions ----
static const bool kIsX = true;
static const float kPixWeight12 = 0.17621312 + 0.12110939 == 0 ? 1 : (0.17621312 + 0.12110939);
static const float kPixWeight34 = 0.06482519 + 0.02702316 == 0 ? 1 : (0.06482519 + 0.02702316);
static const float kPixWeight56 = 0.00877313 + 0.00221820 == 0 ? 1 : (0.00877313 + 0.00221820);
static const float kVertWeight12 = (0.17621312 + 0.12110939) == 0 ? 0 : ( (1 - 0.17621312 / kPixWeight12) + 1 );
static const float kVertWeight34 = (0.06482519 + 0.02702316) == 0 ? 0 : ( (1 - 0.06482519 / kPixWeight34) + 3 );
static const float kVertWeight56 = (0.00877313 + 0.00221820) == 0 ? 0 : ( (1 - 0.00877313 / kPixWeight56) + 5 );

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
