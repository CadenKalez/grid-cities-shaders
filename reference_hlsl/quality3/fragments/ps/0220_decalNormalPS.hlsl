// Shader fragment  [PS slot 220]  decalNormalPS

// ---- declarations / helper functions ----
sampler normalMap : register(s0);  
sampler detailNormalMap   : register(s1);
sampler terrain_edge_gradientMap   : register(s2);

// ---- fragment body (spliced into the generated main()) ----
const float DETAIL_MAP_TILING = 10;
const float TERRAIN_NORMAL_SCALE = 0.333;
const float DETAIL_NORMAL_SCALE = 1.6;  
float3 terrainNormal = tex2D(normalMap, In.texcoord<t0>.xy).xyz * 2.0 - 1.0;
float3 detailNormal = tex2D(detailNormalMap, In.texcoord<t0>.xy * DETAIL_MAP_TILING).xyz * 2.0 - 1.0;
terrainNormal.z *= TERRAIN_NORMAL_SCALE;
terrainNormal = normalize(terrainNormal);
detailNormal.z *= DETAIL_NORMAL_SCALE;
detailNormal = normalize(detailNormal);
float3 tangent = float3(1,0,0);
float3 binormal = normalize(cross(terrainNormal, tangent));
tangent =         normalize(cross(binormal, terrainNormal));
float3x3 tangentSpace = float3x3(binormal, tangent, terrainNormal);
float3 worldNormal = mul(detailNormal, tangentSpace);
worldNormal = normalize(lerp(worldNormal, terrainNormal, 0.25));
float3 bumpNormal = worldNormal;
float specE = 64.0 / 255.0;  
Current.color.a = 1;
