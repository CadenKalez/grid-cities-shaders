// Shader fragment  [PS slot 217]  HeightMapBlur9x9_Y_PS

// ---- samplers ----
sampler screenTex;

// ---- declarations / helper functions ----
float4 blury( sampler screenTex, float2 uv, float4 k[2] )
{
float4 color = tex2D( screenTex, uv );
color.w = color.w * 0.380500
+ ( tex2D( screenTex, k[0].wx ).w + tex2D( screenTex, k[1].wx ).w ) * 0.303140
+ ( tex2D( screenTex, k[0].wy ).w + tex2D( screenTex, k[1].wy ).w ) * 0.006610;
return color;
}

// ---- fragment body (spliced into the generated main()) ----
float2 uv           = In.texcoord<t0>.xy;
float2 texelSize    = In.texcoord<t0>.zw;
float4 k[2];
k[0] = In.texcoord<t1>;
k[1] = In.texcoord<t2>;
Current.color = blury( screenTex, uv, k );
