// Shader fragment  [VS slot 162]  terrainRegionSkirtVS

// ---- uniform parameters ----
uniform struct { float4 mMisc; float4 mTessellation; float4 mMapping; float4 mMorph; float4x4 mMatrix; } terrainRegionInfoVS;   // reg-meta 029302930008000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- declarations / helper functions ----
uniform sampler HeightMapVS : register(s0);

// ---- fragment body (spliced into the generated main()) ----
{
float uvScale = terrainRegionInfoVS.mMisc.y;  
float2 skirtDir = terrainRegionInfoVS.mMisc.zw;
float4 transformedPos = mul(terrainRegionInfoVS.mMatrix, float4(Current.position.xy, 0, 1));
float4 nsew = float4(
skirtDir.y > 0 ? 1 : 0,
skirtDir.y < 0 ? 1 : 0,
skirtDir.x > 0 ? 1 : 0,
skirtDir.x < 0 ? 1 : 0);
float2 heightMapUV = Current.position.xy / uvScale;
heightMapUV += float2(0.5, 0.5);  
heightMapUV.xy = nsew.x > 0 ? float2(heightMapUV.x, 1.0) : heightMapUV.xy;  
heightMapUV.xy = nsew.y > 0 ? float2(heightMapUV.x, 0.0) : heightMapUV.xy;  
heightMapUV.xy = nsew.z > 0 ? float2(1.0, heightMapUV.x) : heightMapUV.xy;  
heightMapUV.xy = nsew.w > 0 ? float2(0.0, heightMapUV.x) : heightMapUV.xy;  
float2 skirtUV = float2(0,0);
skirtUV.x = dot(heightMapUV.xyxy, nsew);  
heightMapUV.xy *= terrainRegionInfoVS.mMapping.xy;
heightMapUV.xy += terrainRegionInfoVS.mMapping.zw;
float height = tex2Dlod(HeightMapVS, float4(heightMapUV.x, heightMapUV.y, 0, 0)).x;  
height *= 2048.0;  
height -= 1024.0;  
skirtUV.y = transformedPos.z < 0 ? 0 : 1;
float waterLevel = terrainRegionInfoVS.mMisc.x;
height = transformedPos.z < 0 ? -1024.0 : max(height, waterLevel);
float3 worldPos = float3(transformedPos.xy, height);
float2 controMapUV = worldPos.xy / 2048.0 + 0.5;  
Current.position = float4(worldPos, 1);
Current.texcoord<t0> = float4(heightMapUV, controMapUV);
Current.texcoord<t1> = float4(skirtDir, skirtUV);
Current.texcoord<t2> = Current.position;
}
