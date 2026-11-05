// Shader fragment  [PS slot 148]  CircleTexturePS

// ---- declarations / helper functions ----
sampler inputTexture : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2Dlod(inputTexture, float4(uv,0,0));
// Alpha reject
clip(texColor.a - 0.1f);
Current.color = texColor * color;
Current.color.a = color.a;
