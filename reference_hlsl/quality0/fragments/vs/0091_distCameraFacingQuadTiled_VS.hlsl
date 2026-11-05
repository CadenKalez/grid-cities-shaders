// Shader fragment  [VS slot 91]  distCameraFacingQuadTiled_VS

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4 customParams[4];   // reg-meta 020602060004000000000008

// ---- declarations / helper functions ----
float3 QuadCorner(float2 uv, float4 position, float4 normal)
{
float3 pos = position.xyz;
pos.x += normal.w * (uv.x * 2 - 1);
pos.y += normal.w * 2 * (1 - uv.y);
return pos;
}

// ---- fragment body (spliced into the generated main()) ----
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
