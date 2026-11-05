// Shader fragment  [PS slot 107]  networkRoadBasicNormalMapPS

// ---- fragment body (spliced into the generated main()) ----
float4 normalMap = tex2D( normalMapSampler, baseUV );
float3 nmapNormal;
nmapNormal.xy = normalMap.ga * 2.0f - 0.9985f;
nmapNormal.z  = sqrt( saturate( 1.0f - dot( nmapNormal.xy, nmapNormal.xy ) ) );
