// Shader fragment  [PS slot 385]  regionCityBuildingsImpostorClipPS

// ---- fragment body (spliced into the generated main()) ----
// scissor window
float4 clipPosition = position; // pre-atlas
clip( float4( 1.0f + clipPosition.xy, 1.0f - clipPosition.xy ) );
