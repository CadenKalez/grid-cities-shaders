// Shader fragment  [VS slot 157]  terrainRegionVS

// ---- uniform parameters ----
uniform struct { float4 mMisc; float4 mTessellation; float4 mMapping; float4 mMorph; float4x4 mMatrix; } terrainRegionInfoVS;   // reg-meta 029302930008000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- declarations / helper functions ----
sampler HeightMapVS : register(s0);

// ---- fragment body (spliced into the generated main()) ----
{
float uvScale = terrainRegionInfoVS.mMisc.y;  
float2 flatPos = Current.position.xy;
float2 gridUV = flatPos.xy / uvScale;  
float4 tessellation = terrainRegionInfoVS.mTessellation.xyzw;  
gridUV *= -1;
float4 morph = float4(0,0,0,0);
morph.x = (gridUV.y > 0) && (abs(gridUV.y) > abs(gridUV.x)) ? tessellation.x : 0;  
morph.y = (gridUV.y < 0) && (abs(gridUV.y) > abs(gridUV.x)) ? tessellation.y : 0;  
morph.z = (gridUV.x > 0) && (abs(gridUV.x) > abs(gridUV.y)) ? tessellation.z : 0;  
morph.w = (gridUV.x < 0) && (abs(gridUV.x) > abs(gridUV.y)) ? tessellation.w : 0;  
float morphAmount = morph.x + morph.y + morph.z + morph.w;
float2 morphStep = terrainRegionInfoVS.mMorph.xy;  
morphStep *= Current.position.zw;  
flatPos += morphStep * morphAmount;
float2 heightMapUV = flatPos.xy / uvScale;
heightMapUV += float2(0.5, 0.5);
heightMapUV.xy *= terrainRegionInfoVS.mMapping.xy;
heightMapUV.xy += terrainRegionInfoVS.mMapping.zw;
float4 transformedPos = mul(terrainRegionInfoVS.mMatrix, float4(flatPos, 0, 1));
flatPos.xy = transformedPos.xy;
float height = tex2Dlod(HeightMapVS, float4(heightMapUV.x, heightMapUV.y, 0, 0)).x;  
height *= 2048.0;  
height -= 1024.0;  
float2 toVertex2D = flatPos.xy - worldCameraPosition.xy;
gridUV = Current.position.xy / uvScale;  
gridUV += 0.5;  
float2 vertexTangent = float2(0,0);
vertexTangent.x = gridUV.x == 0.0 ?  1 : vertexTangent.x;
vertexTangent.x = gridUV.x == 1.0 ? -1 : vertexTangent.x;
vertexTangent.y = gridUV.y == 0.0 ?  1 : vertexTangent.y;
vertexTangent.y = gridUV.y == 1.0 ? -1 : vertexTangent.y;
float dp = dot(vertexTangent, toVertex2D);
float performFix = -sign(dp);
const float fixDistance = 5;  
float fixAmount = smoothstep(3000, 4000, length(toVertex2D));  
float heightDifference = height - worldCameraPosition.z;
float3 toVertex3D = float3(toVertex2D.xy, heightDifference);
toVertex3D = normalize(toVertex3D);
toVertex2D = normalize(toVertex2D);
float dp2 = dot(toVertex3D.xyz, float3(toVertex2D, 0));
fixAmount *= step(0.97, dp2);  
height += fixDistance * fixAmount * performFix;
float3 worldPos = float3(flatPos.xy, height);
float2 controMapUV = worldPos.xy / 2048.0 + 0.5;  
Current.position = float4(worldPos, 1);
Current.texcoord<t0> = float4(heightMapUV, controMapUV);
Current.texcoord<t1> = float4(terrainRegionInfoVS.mMorph);  
Current.texcoord<t2> = Current.position;
}
