// Material shader: Gauss9x9_Y_Shader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 textureSizes[4];
static const bool kIsX = false;
static const float kPixWeight12 = 0.22597815 + 0.09719199 == 0 ? 1 : (0.22597815 + 0.09719199);
static const float kPixWeight34 = 0.02381792 + 0.00332573 == 0 ? 1 : (0.02381792 + 0.00332573);
static const float kPixWeight56 = 0 + 0 == 0 ? 1 : (0 + 0);
static const float kVertWeight12 = (0.22597815 + 0.09719199) == 0 ? 0 : ( (1 - 0.22597815 / kPixWeight12) + 1 );
static const float kVertWeight34 = (0.02381792 + 0.00332573) == 0 ? 0 : ( (1 - 0.02381792 / kPixWeight34) + 3 );
static const float kVertWeight56 = (0 + 0) == 0 ? 0 : ( (1 - 0 / kPixWeight56) + 5 );

void main_vertex()
{
    // --- fragment: Gauss9x9_Y_Shader_VS   (cond 0000000000000000000000000000000000000000000000ff)
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
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler screenTex;
static const bool kIsX = false;
static const float kPixWeight0 = 0.29937241;
static const float kPixWeight12 = 0.22597815 + 0.09719199;
static const float kPixWeight34 = 0.02381792 + 0.00332573;
static const float kPixWeight56 = 0 + 0;
float4 blurx( sampler screenTex, float2 uv, float4 k[2] )
{
float4 color = tex2D( screenTex, uv ) * kPixWeight0
+ ( tex2D( screenTex, k[0].xw ) + tex2D( screenTex, k[1].xw ) ) * kPixWeight12;
if (kPixWeight34 != 0)
color += ( tex2D( screenTex, k[0].yw ) + tex2D( screenTex, k[1].yw ) ) * kPixWeight34;
if (kPixWeight56 != 0)
color += ( tex2D( screenTex, k[0].zw ) + tex2D( screenTex, k[1].zw ) ) * kPixWeight56;
return color;
}
float4 blury( sampler screenTex, float2 uv, float4 k[2] )
{
float4 color = tex2D( screenTex, uv ) * kPixWeight0
+ ( tex2D( screenTex, k[0].wx ) + tex2D( screenTex, k[1].wx ) ) * kPixWeight12;
if (kPixWeight34 != 0)
color += ( tex2D( screenTex, k[0].wy ) + tex2D( screenTex, k[1].wy ) ) * kPixWeight34;
if (kPixWeight56 != 0)
color += ( tex2D( screenTex, k[0].wz ) + tex2D( screenTex, k[1].wz ) ) * kPixWeight56;
return color;
}

void main_pixel()
{
    // --- fragment: Gauss9x9_Y_Shader_PS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv           = In.texcoord<t0>.xy;
    float2 texelSize    = In.texcoord<t0>.zw;
    float4 k[2];
    k[0] = In.texcoord<t1>;
    k[1] = In.texcoord<t2>;
    if (kIsX)
    Current.color = blurx( screenTex, uv, k );
    else
    Current.color = blury( screenTex, uv, k );
}
