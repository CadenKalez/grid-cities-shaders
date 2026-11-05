// Shader fragment  [PS slot 186]  terrainSkirtDepthNormalPS

// ---- uniform parameters ----
uniform struct { float4 mColor; float4 mSkirtNormal; } skirtPS;   // reg-meta 029002900002000000000008

// ---- declarations / helper functions ----
uniform sampler SkirtTextureMap      : register(s0);

// ---- fragment body (spliced into the generated main()) ----
{
float4 worldPos = float4(In.texcoord<t2>.xyz, 1);
float3 skirtNormal = float3(In.texcoord<t1>.xy, 0);
float gloss = 1.0f;
float specPow = 64.0 / 255.0;
Current.color.w = specPow;  
Current.color1 = float4(skirtNormal * 0.5 + 0.5, gloss);
}
