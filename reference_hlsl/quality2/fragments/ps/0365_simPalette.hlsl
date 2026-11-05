// Shader fragment  [PS slot 365]  simPalette

// ---- uniform parameters ----
uniform float4 simPalette;   // reg-meta 02c902c90001000000000008

// ---- declarations / helper functions ----
sampler bodyPaletteTex     : register(s4);
sampler clothesPaletteTex  : register(s5);

// ---- fragment body (spliced into the generated main()) ----
float palV = Current.color.g;
float aoFactor = Current.color.r;
float4 bodyColor    = tex2D(bodyPaletteTex,    float2(simPalette.x, palV));
float4 clothesColor = tex2D(clothesPaletteTex, float2(simPalette.y, palV));
float3 simColor = lerp(bodyColor.rgb, clothesColor.rgb, clothesColor.a) * aoFactor;
Current.color.rgb = simColor;
