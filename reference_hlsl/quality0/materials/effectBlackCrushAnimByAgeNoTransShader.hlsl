// Material shader: effectBlackCrushAnimByAgeNoTransShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (8 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 worldCameraPosition;
uniform float4 gameInfo;
uniform float4 customParams[2];
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
    // --- fragment: effectAnimateTilesByAgeVF   (cond 0000000000000000000000000000000000000000000000ff)
    float tileBlend;
    float2 tileUV;
    {
    float id = Current.texcoord<t0>.w;
    float animBlendRate = customParams[0].x;
    float stripLength = customParams[0].y;
    float t = id * 255 + age * animBlendRate;
    tileBlend = frac( t );
    float4 tile = float4( t - tileBlend, t + 1 - tileBlend, uv.y, uv.y );
    tile /= stripLength;
    tile.xy = frac( tile.xy );
    tile.xy += tile.zw;
    tileUV = tile.xy;
    }
    // --- fragment: effectFadeVF   (cond 0000000000000000000000000000000000000000000000ff)
    float fadeLevel;
    {
    float fadeRate = customParams[0].w;
    fadeLevel = saturate( age * fadeRate );
    }
    // --- fragment: effectBlackCrushVF   (cond 0000000000000000000000000000000000000000000000ff)
    float blackPoint	= fadeLevel;
    float midPoint = ( 1.0 + blackPoint ) * 0.5;
    // --- fragment: effectToClipVF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 clipPos;
    {
    clipPos = mul( float4( quadPos, 1 ), modelToClip );
    }
    // --- fragment: effectBlackCrushAnimOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position            = clipPos;
    Current.color               = color;
    Current.texcoord<t0>        = float4( uv.x, tileUV.x, uv.x, tileUV.y );
    Current.texcoord<t1>.x      = tileBlend;
    Current.texcoord<t1>.y      = 0.0;
    Current.texcoord<t1>.z      = blackPoint;
    Current.texcoord<t1>.w		= midPoint;
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler tileMap : register(s0);
uniform float4 customParams[1];

void main_pixel()
{
    // --- fragment: effectBlackCrushAnimInputPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4  color           = In.color;
    float2  tileUV1         = In.texcoord0.xy;
    float2  tileUV2         = In.texcoord0.zw;
    float   tileBlend       = In.texcoord1.x;
    float   blackPoint		= In.texcoord1.z;
    float   midPoint		= In.texcoord1.w;
    // --- fragment: effectSampleAnimTilePS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 tileTex      = lerp( tex2D( tileMap, tileUV1 ), tex2D( tileMap, tileUV2 ), tileBlend );
    float4 diffuse      = tileTex * color;
    // --- fragment: effectPostMultiply   (cond 0000000000000000000000000000000000000000000000ff)
    diffuse.rgb *= customParams[0].z;
    // --- fragment: effectBlackCrushPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 crush = float4(0, 0, 0, 0);
    if ( diffuse.a < midPoint )
    crush += midPoint * ( diffuse - blackPoint ) / ( midPoint - blackPoint + 0.0001 );
    else
    crush += diffuse;
    Current.color.rgb   = crush.rgb;
    Current.color.a		= crush.a;
}
