// Shader fragment  [VS slot 301]  Gauss8x8_X_Shader_VS

// ---- uniform parameters ----
uniform float4 textureSizes[4];   // reg-meta 022102210004000000400000

// ---- declarations / helper functions ----
static const bool kIsX = true;
static const float kPixWeight12 = 0.23684138 + 0.07867692 == 0 ? 1 : (0.23684138 + 0.07867692);
static const float kPixWeight34 = 0.01253613 + 0.00095809 == 0 ? 1 : (0.01253613 + 0.00095809);
static const float kPixWeight56 = 0 + 0 == 0 ? 1 : (0 + 0);
static const float kVertWeight12 = (0.23684138 + 0.07867692) == 0 ? 0 : ( (1 - 0.23684138 / kPixWeight12) + 1 );
static const float kVertWeight34 = (0.01253613 + 0.00095809) == 0 ? 0 : ( (1 - 0.01253613 / kPixWeight34) + 3 );
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
