// Shader fragment  [PS slot 84]  effectSamplePickTilePS

// ---- declarations / helper functions ----
extern uniform sampler tileMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 tileTex      = tex2D( tileMap, tileUV );
float4 diffuse      = tileTex * color;
