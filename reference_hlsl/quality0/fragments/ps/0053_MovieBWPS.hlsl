// Shader fragment  [PS slot 53]  MovieBWPS

// ---- samplers ----
sampler movie;

// ---- fragment body (spliced into the generated main()) ----
float4 sourceColor = tex2D(movie, In.texcoord0.xy);
Current.color = sourceColor * Current.color;
float lum = dot(Current.color.rgb, float3(0.333, 0.333, 0.333));
Current.color.rgb = float3(lum, lum, lum);
