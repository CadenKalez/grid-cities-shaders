// Shader fragment  [PS slot 259]  vehicleSelfIllumMaskPS

// ---- fragment body (spliced into the generated main()) ----
float3 selfIllumMask = tex2D( selfIllumSampler, uv0 ).rgb;
