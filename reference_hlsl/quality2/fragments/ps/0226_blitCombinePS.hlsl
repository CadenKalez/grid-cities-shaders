// Shader fragment  [PS slot 226]  blitCombinePS

// ---- uniform parameters ----
uniform struct { float4 mXYWH; float4 mScaleAndBias; } blitInfo;   // reg-meta 029702970002000000000008

// ---- declarations / helper functions ----
sampler srcMap0 : register(s0);
sampler srcMap1 : register(s1);
sampler srcMap2 : register(s2);
sampler srcMap3 : register(s3);
sampler alphaMask : register(s4);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float4 texels = float4(
tex2D(srcMap0, uv).x,
tex2D(srcMap1, uv).x,
tex2D(srcMap2, uv).x,
tex2D(srcMap3, uv).x);
float4 mask;
mask = tex2D(alphaMask, uv).aaaa;
mask = sign(saturate(mask));
texels = saturate(texels - (mask * blitInfo.mXYWH));
texels *= blitInfo.mScaleAndBias.xxxx;
texels += blitInfo.mScaleAndBias.yyyy;
Current.color = texels;
