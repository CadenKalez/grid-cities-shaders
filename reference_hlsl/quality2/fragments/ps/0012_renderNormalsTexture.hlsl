// Shader fragment  [PS slot 12]  renderNormalsTexture

// ---- samplers ----
sampler diffuseTextureSampler;

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
float3 normal = diffuseTexture.rgb * 2 - 1; // unpack
normal = normalize(normal);
Current.color = float4(normal * 0.5 + 0.5,1);
