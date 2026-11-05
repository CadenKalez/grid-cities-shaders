// Shader fragment  [VS slot 107]  effectAnimateTilesVF

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float tileBlend;
float2 tileUV;
{
float id = Current.texcoord<t0>.w;
float animBlendRate = customParams[0].x;
float stripLength = customParams[0].y;
float t = id * 255 + gameInfo.x * animBlendRate;
tileBlend = frac( t );
float4 tile = float4( t - tileBlend, t + 1 - tileBlend, uv.y, uv.y );
tile /= stripLength;
tile.xy = frac( tile.xy );
tile.xy += tile.zw;
tileUV = tile.xy;
}
