// Shader fragment  [PS slot 460]  applyLightingFogPS

// ---- declarations / helper functions ----
sampler fogTex : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(fogTex, In.texcoord0.xy);
Current.color.rgb = texColor.rgb;
Current.color.a = texColor.a;
