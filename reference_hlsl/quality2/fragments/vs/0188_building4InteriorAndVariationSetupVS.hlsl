// Shader fragment  [VS slot 188]  building4InteriorAndVariationSetupVS

// ---- fragment body (spliced into the generated main()) ----
float3 interiorThresholds = instanceData.rgb;
float buildingVariation  = BuildingPaletteVariationVS(int(instanceData.w));
