// Shader fragment  [PS slot 128]  roadGuideDashedPS

// ---- declarations / helper functions ----
sampler textureSampler : register(s0);

// ---- fragment body (spliced into the generated main()) ----
// NB: We expect the UV coords to have been scaled before being passed in as part
// of the vertex data.
float4 texColor = tex2D(textureSampler, In.texcoord0.xy);
// Adjust opacity
Current.color = In.color * texColor * 0.50f;
Current.color.a = texColor.a * 0.50f;
