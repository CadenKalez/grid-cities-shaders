// Shader fragment  [VS slot 255]  regionCityBuildingsSetupVS

// ---- declarations / helper functions ----
static const int2  kPaletteSize = int2(256, 8);
static const float2 kPaletteInvSize = 1.0 / kPaletteSize;
// Convert from byte-represented color (0-1) to U value within texture
float BuildingPaletteVS(float palU)
{
// move to corner of 2x2 block
palU = palU * ((kPaletteSize.x - 1) * kPaletteInvSize.x);
return palU;
}
float BuildingPaletteVariationVS(int buildingType)
{
return buildingType * kPaletteInvSize.y;
}

// ---- fragment body (spliced into the generated main()) ----
// unpack rest of data from color
float palU  = BuildingPaletteVS( In.color.r );
float palU2 = BuildingPaletteVS( In.color.g );
// unpack other texture coords
float2 tileSize            = In.texcoord1.xy;
float2 tileOffset          = In.texcoord1.zw;
float2 tileSize2           = In.texcoord2.xy;
float2 tileOffset2         = In.texcoord2.zw;
float2 tilePadding         = In.texcoord3.xy;
float2 interiorRoomInvSize = In.texcoord3.zw;
float2 uv  = In.texcoord0.xy / abs( tileSize );
float2 uv2 = In.texcoord0.zw / abs( tileSize2 );
uv2 += ( tilePadding * 0.5f );
uv2 /= ( 1.0f + tilePadding );
