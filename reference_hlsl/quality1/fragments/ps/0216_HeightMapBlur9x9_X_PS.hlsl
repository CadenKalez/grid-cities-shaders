// Shader fragment  [PS slot 216]  HeightMapBlur9x9_X_PS

// ---- samplers ----
sampler screenTex;

// ---- declarations / helper functions ----
float4 blurx( sampler screenTex, float2 uv, float4 k[2] )
{
float4 color = tex2D( screenTex, uv );
color.w = color.w * 0.380500
+ ( tex2D( screenTex, k[0].xw ).w + tex2D( screenTex, k[1].xw ).w ) * 0.303140
+ ( tex2D( screenTex, k[0].yw ).w + tex2D( screenTex, k[1].yw ).w ) * 0.006610;
return color;
}

// ---- fragment body (spliced into the generated main()) ----
float2 uv           = In.texcoord<t0>.xy;
float2 texelSize    = In.texcoord<t0>.zw;
float4 k[2];
k[0] = In.texcoord<t1>;
k[1] = In.texcoord<t2>;
Current.color = blurx( screenTex, uv, k );
