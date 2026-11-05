// Shader fragment  [PS slot 108]  networkRoadBasicSpecMapPS

// ---- fragment body (spliced into the generated main()) ----
float3 specMap      = tex2D( specSampler, baseUV ).rgb;
float  specE        = ( specMap.r * specMap.r * specMap.r + 1.0f / 1024.0f ) * 1024.0f;
float  specStrength = specMap.b;
float  gloss        = specMap.r;
