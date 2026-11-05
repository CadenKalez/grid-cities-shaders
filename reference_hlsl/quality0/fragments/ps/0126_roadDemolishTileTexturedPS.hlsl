// Shader fragment  [PS slot 126]  roadDemolishTileTexturedPS

// ---- declarations / helper functions ----
sampler textureSampler : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(textureSampler, In.texcoord0.xy);
Current.color.rgb = (In.color.rgb * texColor.rgb) * texColor.a;
Current.color.a = texColor.a;
