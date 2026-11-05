// Shader fragment  [PS slot 219]  terrainThicknessPS

// ---- declarations / helper functions ----
extern uniform sampler HeightMap1 : register(s0);  
extern uniform sampler HeightMap2 : register(s1);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
float p1 = tex2D(HeightMap1, uv ).x;  
float p2 = tex2D(HeightMap2, uv ).x;  
float thickness = saturate(p1-p2);
Current.color = float4(thickness, 0, 0, 0);
