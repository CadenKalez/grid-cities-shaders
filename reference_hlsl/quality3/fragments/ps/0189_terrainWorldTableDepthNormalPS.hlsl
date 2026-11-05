// Shader fragment  [PS slot 189]  terrainWorldTableDepthNormalPS

// ---- declarations / helper functions ----
uniform sampler TableTextureMap      : register(s0);

// ---- fragment body (spliced into the generated main()) ----
{
half4 worldPos = half4(In.texcoord<t2>.xyz, 1);
half3 tableNormal = half3(0,0,1);
half gloss = 1.0f;
half specPow = 64.0 / 255.0;
Current.color.w = specPow;  
Current.color1 = half4(tableNormal * 0.5 + 0.5, gloss);
}
