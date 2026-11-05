// Shader fragment  [PS slot 56]  webViewApplyOpacityTexture

// ---- samplers ----
sampler diffuseTextureSampler;

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
Current.color = diffuseTexture * make_float4(Current.color.a); // just use opacity and ignore the other channels for now
