// Material shader: HeightMapExpand_Y_Shader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 samplerInfo0;

void main_vertex()
{
    // --- fragment: CreateHeightMapExpand_Y_VS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 texelSize        = samplerInfo0.zw;
    Current.position        = float4( In.position.xy, 0, 1 );
    Current.texcoord<t0>    = float4( In.texcoord0.xy, texelSize );
    Current.texcoord<t1>    = In.texcoord0.xyxy + float4( 0, 1, 0, 2 ) * texelSize.xyxy;
    Current.texcoord<t2>    = In.texcoord0.xyxy - float4( 0, 1, 0, 2 ) * texelSize.xyxy;
    Current.texcoord<t3>    = In.texcoord0.xyxy + float4( 0,-3, 0, 3 ) * texelSize.xyxy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler screenTex;
float3 depthAndAlpha( sampler screenTex, float2 uv )
{
float4 map = tex2D(screenTex, uv);
return float3( dot( map.xy, float2( 1.0, 1.0 / 255.0 ) ), map.z, map.w);
}
float4 findmin( sampler screenTex, float2 uv, float4 k[3] )
{
float3 baseHeightAlpha = depthAndAlpha( screenTex, uv );
float3 nextHeightAlpha;
float combinedHeight = baseHeightAlpha.y > 0 ? baseHeightAlpha.x : 2;
float heightWeight = baseHeightAlpha.y;
for( int i = 0; i < 3; i++ )
{
nextHeightAlpha = depthAndAlpha( screenTex, k[i].xy );
combinedHeight = nextHeightAlpha.y > 0 ? min(combinedHeight, nextHeightAlpha.x) : combinedHeight;
heightWeight += nextHeightAlpha.y;
nextHeightAlpha = depthAndAlpha( screenTex, k[i].zw );
combinedHeight = nextHeightAlpha.y > 0 ? min(combinedHeight, nextHeightAlpha.x) : combinedHeight;
heightWeight += nextHeightAlpha.y;
}
float resultHeight = lerp(baseHeightAlpha.x, combinedHeight, saturate(heightWeight) * 1);
float resultWeight = max(baseHeightAlpha.y, saturate(heightWeight / 7));
//resultHeight = lerp(resultHeight, baseHeightAlpha.x, baseHeightAlpha.y);
resultHeight = resultHeight * 255.0 + (0.5/255);
return float4(floor(resultHeight) / 255.0, floor(frac(resultHeight)*255.0) / 255.0, resultWeight, baseHeightAlpha.z);  
}

void main_pixel()
{
    // --- fragment: CreateHeightMapExpandPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv           = In.texcoord<t0>.xy;
    float2 texelSize    = In.texcoord<t0>.zw;
    float4 k[3];
    k[0] = In.texcoord<t1>;
    k[1] = In.texcoord<t2>;
    k[2] = In.texcoord<t3>;
    Current.color = findmin( screenTex, uv, k );
}
