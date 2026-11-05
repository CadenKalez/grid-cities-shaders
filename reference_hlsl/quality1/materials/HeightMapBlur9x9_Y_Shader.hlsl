// Material shader: HeightMapBlur9x9_Y_Shader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 samplerInfo0;

void main_vertex()
{
    // --- fragment: HeightMapBlur9x9_Y_VS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv               = In.texcoord0.xy;
    float2 texelSize        = samplerInfo0.zw;
    Current.position        = float4( In.position.xy, 0, 1 );
    Current.texcoord<t0>    = float4( uv, texelSize );
    Current.texcoord<t1>    = In.texcoord0.yyyx + float4( 1.203511, 3.039779, 0, 0 ) * texelSize.yyyx;
    Current.texcoord<t2>    = In.texcoord0.yyyx - float4( 1.203511, 3.039779, 0, 0 ) * texelSize.yyyx;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler screenTex;
float4 blury( sampler screenTex, float2 uv, float4 k[2] )
{
float4 color = tex2D( screenTex, uv );
color.w = color.w * 0.380500
+ ( tex2D( screenTex, k[0].wx ).w + tex2D( screenTex, k[1].wx ).w ) * 0.303140
+ ( tex2D( screenTex, k[0].wy ).w + tex2D( screenTex, k[1].wy ).w ) * 0.006610;
return color;
}

void main_pixel()
{
    // --- fragment: HeightMapBlur9x9_Y_PS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv           = In.texcoord<t0>.xy;
    float2 texelSize    = In.texcoord<t0>.zw;
    float4 k[2];
    k[0] = In.texcoord<t1>;
    k[1] = In.texcoord<t2>;
    Current.color = blury( screenTex, uv, k );
}
