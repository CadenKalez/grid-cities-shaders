// Shader fragment  [PS slot 213]  copyHeightMapToRG

// ---- declarations / helper functions ----
sampler heightMapSampler : register(s14);

// ---- fragment body (spliced into the generated main()) ----
float baseHeight = tex2D(heightMapSampler, In.texcoord<t0>.xy).x;
float final = baseHeight * 255.0;
Current.color.rgba = float4(floor(final) / 255.0, floor(frac(final)*255.0) / 255.0, 0, 0);
