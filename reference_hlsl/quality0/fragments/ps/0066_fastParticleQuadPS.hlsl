// Shader fragment  [PS slot 66]  fastParticleQuadPS

// ---- samplers ----
sampler diffuse;

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(diffuse, In.texcoord<t0>);
Current.color = Current.color * texColor;
