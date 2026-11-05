// Shader fragment  [PS slot 67]  defaultQuadSetShaderPS

// ---- samplers ----
sampler diffuse;

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(diffuse, In.texcoord<t0>.xy).xyzw;
Current.color = Current.color * texColor;
