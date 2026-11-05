// Shader fragment  [VS slot 83]  particleQuadVS

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
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
