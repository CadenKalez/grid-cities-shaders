// Material shader: effectAnimNoTransShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (6 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 worldCameraPosition;
uniform float4 gameInfo;
uniform float4 customParams[2];
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: effectNoTransSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord0.xy;
    float scale = 1; // scale is only on cpu
    Current.texcoord<t0>.w = Current.color1.w; // transfer id
    // --- fragment: effectSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float age = modelPosition.w;
    float4 color = In.color;
    float3 cameraPos = worldCameraPosition.xyz;
    float3 toCamera = cameraPos - modelPosition.xyz;
    float cameraDist = length( toCamera );
    float3 toCamNormal = toCamera / cameraDist;
    // --- fragment: effectNoTransVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 quadPos;
    {
    quadPos = modelPosition.xyz;
    }
    // --- fragment: effectAnimateTilesVF   (cond 0000000000000000000000000000000000000000000000ff)
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
    // --- fragment: effectToClipVF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 clipPos;
    {
    clipPos = mul( float4( quadPos, 1 ), modelToClip );
    }
    // --- fragment: effectNoTransOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position            = clipPos;
    Current.color               = color;
    Current.texcoord<t0>.xy     = uv;
    Current.texcoord<t0>.zw     = float2(0, 0);
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler tileMap : register(s0);
uniform float4 customParams[1];

void main_pixel()
{
    // --- fragment: effectInputAnimPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4  color           = In.color;
    float2  tileUV1         = In.texcoord0.xy;
    float2  tileUV2         = In.texcoord0.zw;
    float   tileBlend       = In.texcoord1.x;
    float2  uv              = In.texcoord1.zw;
    // --- fragment: effectSampleAnimTilePS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 tileTex      = lerp( tex2D( tileMap, tileUV1 ), tex2D( tileMap, tileUV2 ), tileBlend );
    float4 diffuse      = tileTex * color;
    // --- fragment: effectPostMultiply   (cond 0000000000000000000000000000000000000000000000ff)
    diffuse.rgb *= customParams[0].z;
    // --- fragment: effectPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb   = diffuse.rgb;
    Current.color.a		= diffuse.a;
}
