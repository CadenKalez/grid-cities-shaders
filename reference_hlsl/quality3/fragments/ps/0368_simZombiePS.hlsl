// Shader fragment  [PS slot 368]  simZombiePS

// ---- uniform parameters ----
uniform float4 gameInfo;   // reg-meta 024802480001000000000008

// ---- fragment body (spliced into the generated main()) ----
const float3 kBodyEmissive = float3(1,8,0);
const float3 kClothesEmissive = float3(0,0,0);
float3 glowAmount = lerp(kBodyEmissive, kClothesEmissive, clothesColor.a);
Current.color.rgb += glowAmount;
