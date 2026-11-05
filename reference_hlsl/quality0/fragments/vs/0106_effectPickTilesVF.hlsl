// Shader fragment  [VS slot 106]  effectPickTilesVF

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float2 tileUV;
{
float id = Current.texcoord<t0>.w;
float stripLength = customParams[0].y;
float t = id * 255;
float2 tile = float2( t, uv.y );
tile /= stripLength;
tile.x = frac( tile.x );
tile.x += tile.y;
tileUV = tile.xy;
}
