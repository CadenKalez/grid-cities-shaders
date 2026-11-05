// Shader fragment  [VS slot 187]  building4ConstructionRubbleInteriorAndVariationSetupVS

// ---- fragment body (spliced into the generated main()) ----
float3 interiorThresholds = float3(0,0,0); // force all interiors to dark
float  buildingVariation = BuildingPaletteVariationVS(int(instanceData.r)); // instanceData.w holds construction/rubble param
