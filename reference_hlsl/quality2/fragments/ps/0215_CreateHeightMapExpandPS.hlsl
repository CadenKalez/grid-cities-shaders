// Shader fragment  [PS slot 215]  CreateHeightMapExpandPS

// ---- samplers ----
sampler screenTex;

// ---- declarations / helper functions ----
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

// ---- fragment body (spliced into the generated main()) ----
float2 uv           = In.texcoord<t0>.xy;
float2 texelSize    = In.texcoord<t0>.zw;
float4 k[3];
k[0] = In.texcoord<t1>;
k[1] = In.texcoord<t2>;
k[2] = In.texcoord<t3>;
Current.color = findmin( screenTex, uv, k );
