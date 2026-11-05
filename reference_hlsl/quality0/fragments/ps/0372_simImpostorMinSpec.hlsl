// Shader fragment  [PS slot 372]  simImpostorMinSpec

// ---- fragment body (spliced into the generated main()) ----
float3 clipPosition = In.texcoord<t1>.xyz;
float3 vertexNormal = In.texcoord<t2>.xyz;
clip(float4(1 + clipPosition.xy, 1 - clipPosition.xy));
float4 texColor = tex2D(Sampler<s0>, In.texcoord<t0>.xy);
Current.color.rgba = texColor;
