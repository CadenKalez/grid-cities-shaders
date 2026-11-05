// Material shader: particleQuad
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4 worldCameraDirection;

void main_vertex()
{
    // --- fragment: particleQuadVS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = Current.texcoord0.xy;
    float4 hPos;
    float3 up    = Current.normal.xyz;
    float3 right = -cross(up, worldCameraDirection.xyz);
    float  size  = Current.normal.w * 0.5;
    hPos.xyz = Current.position.xyz;
    hPos.xyz += right * size * (uv.x * 2 - 1);
    hPos.xyz -= up    * size * (uv.y * 2 - 1);
    hPos.w = 1;
    Current.position = mul(hPos, modelToClip);
    int2 texTiles = int2(4, 4);
    int pID = int(floor(Current.texcoord0.w * 255));
    float2 whichTile = float2(pID/texTiles.x, pID % texTiles.y);
    float2 tiledUV = (Current.texcoord0.xy + whichTile) / texTiles;
    Current.texcoord0 = tiledUV;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuse;

void main_pixel()
{
    // --- fragment: particleQuadPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(diffuse, Current.texcoord0);
    Current.color = Current.color * texColor;
}
