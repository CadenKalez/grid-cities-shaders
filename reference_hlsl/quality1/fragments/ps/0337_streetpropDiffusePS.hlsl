// Shader fragment  [PS slot 337]  streetpropDiffusePS

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseTexture = tex2D(diffuseSampler, In.texcoord<t0>.xy);
Current.color.rgba = diffuseTexture.rgba;
