// Shader fragment  [PS slot 487]  Gauss11x11_X_Shader_PS

// ---- samplers ----
sampler screenTex;

// ---- declarations / helper functions ----
static const bool kIsX = true;
static const float kPixWeight0 = 0.23938349;
static const float kPixWeight12 = 0.19994990 + 0.11652046;
static const float kPixWeight34 = 0.04737368 + 0.01343774;
static const float kPixWeight56 = 0.00265931 + 0.00036717;
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

// ---- fragment body (spliced into the generated main()) ----
float2 uv           = In.texcoord<t0>.xy;
float2 texelSize    = In.texcoord<t0>.zw;
float4 k[2];
k[0] = In.texcoord<t1>;
k[1] = In.texcoord<t2>;
if (kIsX)
Current.color = blurx( screenTex, uv, k );
else
Current.color = blury( screenTex, uv, k );
