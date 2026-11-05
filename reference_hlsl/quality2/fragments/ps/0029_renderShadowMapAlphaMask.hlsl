// Shader fragment  [PS slot 29]  renderShadowMapAlphaMask

// ---- declarations / helper functions ----
extern uniform sampler diffuseTexture : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float texAlpha = tex2D(diffuseTexture, In.texcoord<t0>.xy).a;
clip(texAlpha - 0.5);
float depth = saturate(In.texcoord<t0>.w);
Current.color = float4( depth, frac(depth * 256), depth, 1 );
