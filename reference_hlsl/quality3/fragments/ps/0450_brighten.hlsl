// Shader fragment  [PS slot 450]  brighten

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float brightenAmount = 0.2;
Current.color = tex2D(map, In.texcoord0);
Current.color.rgb = lerp(brightenAmount, 1, Current.color.rgb);
