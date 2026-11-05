// Shader fragment  [PS slot 146]  t2Texture

// ---- declarations / helper functions ----
sampler inputTexture : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 texValue = tex2D(inputTexture, uv);
clip(texValue.a - 0.1);
color *= texValue;
Current.color = color;
