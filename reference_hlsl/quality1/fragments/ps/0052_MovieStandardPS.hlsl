// Shader fragment  [PS slot 52]  MovieStandardPS

// ---- samplers ----
sampler movie;

// ---- fragment body (spliced into the generated main()) ----
float4 sourceColor = tex2D(movie, In.texcoord0.xy);
Current.color = sourceColor * Current.color;
