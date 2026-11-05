// Shader fragment  [PS slot 69]  ScreenEffectsTextureShaderPS

// ---- declarations / helper functions ----
extern uniform sampler additionalTex : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(additionalTex, In.texcoord<t0>.xy);
Current.color.xyz = In.color.rgb * texColor.rgb;
Current.color.w   = In.color.w * texColor.w;
