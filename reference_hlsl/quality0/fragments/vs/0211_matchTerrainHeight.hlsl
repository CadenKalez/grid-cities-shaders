// Shader fragment  [VS slot 211]  matchTerrainHeight

// ---- declarations / helper functions ----
uniform sampler HeightMapVS : register(s0);

// ---- fragment body (spliced into the generated main()) ----
int lotsIndex4 = toInt(In.indices.w);
float heightMatchAmount = saturate(lotsIndex4);
float height = tex2Dlod(HeightMapVS, float4(topDownUV, 0, 0)).x;  
height *= 2048.0;  
height -= 1024.0;  
Current.position.z = lerp(Current.position.z,min(Current.position.z,height),heightMatchAmount);
