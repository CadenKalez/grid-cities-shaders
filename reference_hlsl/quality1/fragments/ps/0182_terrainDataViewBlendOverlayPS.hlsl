// Shader fragment  [PS slot 182]  terrainDataViewBlendOverlayPS

// ---- fragment body (spliced into the generated main()) ----
float filterZeroPointPrimary = contourInfo.mContourInfo[0].w;
float filterZeroPointSecondary = contourInfo.mContourInfo[1].w;
float tiers2 = contourInfo.mContourInfo[1].x;
float bottomFilter2 = contourInfo.mContourInfo[1].y;
float topFilter2 = contourInfo.mContourInfo[1].z;
float3 secondaryContourColor = contourInfo.mMapColor[1].rgb;
float3 primaryContourColorNegative = contourInfo.mMapColorNegatives[0].rgb;
float3 secondaryContourColorNegative = contourInfo.mMapColorNegatives[1].rgb;
// Secondary ecoMap acts as a selection mask such that if there are non-zero values
// in the second map, the secondary color overrides the primary color. We then
// perform a final blend with the chosen base color and the primary color.
float primaryWeight = contourInfo.mMapColor[0].a;
float selectionWeight = contourInfo.mMapColor[1].a;
// Compute which band the zero point would normally fall in. This is the number of bands
// between the zero point and the bottom cutoff of the map ranges, and is the number
// of tiers we'll pass in to posterize.
float band_width = (topFilter - bottomFilter) / tiers;
float band = ceil((filterZeroPointPrimary - bottomFilter) / band_width);
float remainingBands = tiers - band;
// Figure out which color we should ultimately output. Positive select means we should use
// postive contour color whereas negative will clamp to 0 and indicate we should use the
// negative contour color. If filterZeroPoint occupies the 0th band, then it is likely to be
// very close to the bottomFilter and so we treat that as if there was no zero point defined.
float select = float(ecoMap.x > filterZeroPointPrimary || band == 0);
float invSelect = 1.0f - select;
// Posterize the colors
float gradient = posterize(ecoMap.x, max(band,1.0), bottomFilter, filterZeroPointPrimary);
float gradient2 = posterize(ecoMap.x, remainingBands, filterZeroPointPrimary, topFilter);
float3 contourColorNegative = lerp(primaryContourColorNegative, globalDataView.baseColor.rgb, gradient);
float3 contourColorPositive = lerp(globalDataView.baseColor.rgb, primaryContourColor, gradient2);
float3 primaryContourColorOut = contourColorPositive * select + contourColorNegative * invSelect;
// Repeat for secondary ecomap
band_width = (topFilter2 - bottomFilter2) / tiers2;
band = ceil((filterZeroPointSecondary - bottomFilter2) / band_width);
remainingBands = tiers2 - band;
// Figure out which color we should ultimately output. Positive select means we should use
// postive contour color whereas negative will clamp to 0 and indicate we should use the
// negative contour color. If filterZeroPoint occupies the 0th band, then it is likely to be
// very close to the bottomFilter and so we treat that as if there was no zero point defined.
select = float(ecoMap.y > filterZeroPointSecondary || band == 0);
invSelect = 1.0f - select;
// Posterize the colors
gradient = posterize(ecoMap.y, max(band,1.0), bottomFilter2, filterZeroPointSecondary);
gradient2 = posterize(ecoMap.y, remainingBands, filterZeroPointSecondary, topFilter2);
contourColorNegative = lerp(secondaryContourColorNegative, globalDataView.baseColor.rgb, gradient);
contourColorPositive = lerp(globalDataView.baseColor.rgb, secondaryContourColor, gradient2);
float3 secondaryContourColorOut = contourColorPositive * select + contourColorNegative * invSelect;
// At this point, we've chosen whether to use the positive or negative color bands for each ecomap.
// Now we need to determine which colors to select for the final blending. We always assume that the
// secondary ecomap has a higher priority than the primary ecomap.
select = float(gradient2 > 0);
invSelect = 1.0f - select;
float3 selectionColor = secondaryContourColorOut * select + primaryContourColorOut * invSelect;
// Determine final output color
float3 color = selectionColor * selectionWeight + primaryContourColorOut * primaryWeight;
