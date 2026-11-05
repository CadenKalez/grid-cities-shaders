// Shader fragment  [PS slot 346]  sampleTreeTextures

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseMap = tex2D(Sampler<s0>, In.texcoord<t0>);
float4 normalMap = tex2D(Sampler<s1>, In.texcoord<t0>);
float4 aoMap = tex2D(Sampler<s2>, In.texcoord<t1>);
Current.color *= diffuseMap;
Current.color *= aoMap;
float3 nmapNormal = normalMap.rgb * 2 - 0.9985;
float gloss = 0;
float specE = 1;
float specStrength = 0;
