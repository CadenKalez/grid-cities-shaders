// Shader fragment  [PS slot 184]  blendScreenPS

// ---- declarations / helper functions ----
sampler2D contourTerrainSampler : register(s8);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>;
float4 terrainColor = tex2D(contourTerrainSampler, uv);
clip( terrainColor.a < 0.1f ? -1:1 );
Current.color.a = 0.75;
Current.color.rgb = terrainColor.rgb;
