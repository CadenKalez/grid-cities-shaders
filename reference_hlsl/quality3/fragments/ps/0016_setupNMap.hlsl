// Shader fragment  [PS slot 16]  setupNMap

// ---- fragment body (spliced into the generated main()) ----
float4 specNMap = tex2D(Sampler<s0>, In.texcoord0.xy);
float3 nmapNormal = specNMap.rgb * 2 - 0.9985;
nmapNormal.z *= bumpFactor;
specStrength *= specNMap.a ;
gloss        *= specNMap.a;
