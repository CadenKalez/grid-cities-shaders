// Shader fragment  [PS slot 85]  effectSampleAnimTilePS

// ---- declarations / helper functions ----
extern uniform sampler tileMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 tileTex      = lerp( tex2D( tileMap, tileUV1 ), tex2D( tileMap, tileUV2 ), tileBlend );
float4 diffuse      = tileTex * color;
