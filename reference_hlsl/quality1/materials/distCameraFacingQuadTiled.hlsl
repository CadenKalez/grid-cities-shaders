// Material shader: distCameraFacingQuadTiled
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 cameraToWorld;
uniform float4 worldCameraDirection;
uniform float4 gameInfo;
uniform float4 customParams[4];
float3 QuadCorner(float2 uv, float4 position, float4 normal)
{
float3 pos = position.xyz;
pos.x += normal.w * (uv.x * 2 - 1);
pos.y += normal.w * 2 * (1 - uv.y);
return pos;
}

void main_vertex()
{
    // --- fragment: distCameraFacingQuadTiled_VS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord0.xy;
    uv.x += sin(gameInfo.x * In.position.w * customParams[0].y) * (1 - In.texcoord0.y) * (0) * customParams[0].x;
    float4 hPos;
    hPos.xyz = QuadCorner(uv, In.position, In.normal);
    hPos.w = 1;
    // hPos.z += max(0, vertIn.uv0.y) * vertIn.position.w;
    // hPos.z += vertIn.uv0.w * 1;
    Current.position = mul(hPos, modelToClip);
    Current.texture0 = In.texture0.xy;
    if ((true))
    {
    int2 texTiles = int2(4, 4);
    int pID = int(floor(In.texcoord0.w * 255));
    float2 whichTile = float2(pID % texTiles.y, pID / texTiles.x);
    float2 tiledUV = (In.texcoord0.xy + whichTile) / texTiles;
    Current.texcoord0 = tiledUV;
    }
    Current.color = In.color;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler sourceTex;

void main_pixel()
{
    // --- fragment: distCameraFacingQuadTiled_PS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(sourceTex, In.texcoord0);
    Current.color = In.color * texColor;
}
