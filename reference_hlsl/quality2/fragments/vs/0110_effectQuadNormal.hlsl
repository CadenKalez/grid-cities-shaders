// Shader fragment  [VS slot 110]  effectQuadNormal

// ---- fragment body (spliced into the generated main()) ----
float3 normal = normalize(-0.125 * worldCameraDirection.xyz + quadPos - modelPosition.xyz); // normalize( -0.2 * In.normal.xyz + quadPos - modelPosition.xyz );
