// Shader fragment  [PS slot 459]  uiQuadPF

// ---- declarations / helper functions ----
sampler2D uiTex : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(uiTex, In.texcoord<t0>.xy);
clip (texColor.a - 0.1f);
Current.color.rgb = texColor.rgb * texColor.a * In.color.a;
Current.color.a = texColor.a * In.color.a;
