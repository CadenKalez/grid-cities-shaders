// Shader fragment  [PS slot 20]  shShowSpec

// ---- fragment body (spliced into the generated main()) ----
Current.color.rgb = float3(specStrength, specE / kSpecExponentMaxValue, gloss);
