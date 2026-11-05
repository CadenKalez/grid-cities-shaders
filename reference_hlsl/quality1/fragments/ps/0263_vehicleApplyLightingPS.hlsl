// Shader fragment  [PS slot 263]  vehicleApplyLightingPS

// ---- fragment body (spliced into the generated main()) ----
// Modulate with diffuse light contributions.
finalColor = finalColor * shColorDiff;
// Add specular contributions.
finalColor += ( finalColor * shColorSpec ) + ( specularColor * spec );
