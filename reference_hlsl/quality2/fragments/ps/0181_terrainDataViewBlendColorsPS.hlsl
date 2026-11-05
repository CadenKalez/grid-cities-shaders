// Shader fragment  [PS slot 181]  terrainDataViewBlendColorsPS

// ---- fragment body (spliced into the generated main()) ----
// Secondary ecoMap drives the lerp between main color and secondary color.
// Primary ecoMap drives the opacity of the current color. Shader data is passed in
// such that if there is only one ecomap, contourColour ends up lerping between
// the same color, which is why there isn't a separate shader for no combined
// ecomap case.
// Posterize primary map
float gradient = posterize(ecoMap.x, tiers, bottomFilter, topFilter);
float3 secondaryContourColor = contourInfo.mMapColor[1].rgb;
float weight = saturate((ecoMap.y - 0.001f) / (0.1f - 0.001f));
float3 contourColor = lerp(primaryContourColor, secondaryContourColor, weight);
float3 color = lerp(globalDataView.baseColor.rgb, contourColor, gradient);
