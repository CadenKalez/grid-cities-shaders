// Shader fragment  [PS slot 254]  vehicleSetupSHParams

// ---- fragment body (spliced into the generated main()) ----
float3 specMap = tex2D( specSampler, uv0 ).rgb;
float specE        = ( specMap.r * specMap.r * specMap.r + 1.0f / 1024.0f ) * 1024.0f;
float roughness    = specMap.g;
float specStrength = specMap.b;
float gloss        = specMap.r;
