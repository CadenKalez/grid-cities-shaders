// Material shader: effectPickShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (6 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 worldCameraPosition;
uniform float4 worldCameraDirection;
uniform float4 gameInfo;
uniform float4 customParams[2];
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: effectTransSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = Current.color1.rg;
    float scale = In.normal.w;
    {
    Current.texcoord<t0> = Current.color1;
    }
    // --- fragment: effectSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float age = modelPosition.w;
    float4 color = In.color;
    float3 cameraPos = worldCameraPosition.xyz;
    float3 toCamera = cameraPos - modelPosition.xyz;
    float cameraDist = length( toCamera );
    float3 toCamNormal = toCamera / cameraDist;
    // --- fragment: effectCameraFaceVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 quadPos;
    {
    float3 up = normalize( In.normal.xyz );
    float3 tangent  = cross( worldCameraDirection.xyz, up );
    tangent = normalize( tangent );
    up = normalize( cross( tangent, worldCameraDirection.xyz ) );
    quadPos = modelPosition.xyz;
    quadPos += tangent * scale * (uv.x - 0.5);
    quadPos += up * scale * (0.5 - uv.y);
    }
    // --- fragment: effectPickTilesVF   (cond 0000000000000000000000000000000000000000000000ff)
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
    // --- fragment: effectToClipVF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 clipPos;
    {
    clipPos = mul( float4( quadPos, 1 ), modelToClip );
    }
    // --- fragment: effectOutputPickVF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position            = clipPos;
    Current.color               = color;
    Current.texcoord<t0>.xy     = float2( uv.x, tileUV.x );
    Current.texcoord<t0>.zw     = 0.0;
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler tileMap : register(s0);
uniform float4 customParams[1];

void main_pixel()
{
    // --- fragment: effectInputPickPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4  color           = In.color;
    float2  tileUV          = In.texcoord0.xy;
    // --- fragment: effectSamplePickTilePS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 tileTex      = tex2D( tileMap, tileUV );
    float4 diffuse      = tileTex * color;
    // --- fragment: effectPostMultiply   (cond 0000000000000000000000000000000000000000000000ff)
    diffuse.rgb *= customParams[0].z;
    // --- fragment: effectPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb   = diffuse.rgb;
    Current.color.a		= diffuse.a;
}
