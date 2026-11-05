// Shader fragment  [PS slot 224]  blitPS

// ---- uniform parameters ----
uniform struct { float4 mXYWH; float4 mScaleAndBias; } blitInfo;   // reg-meta 029702970002000000000008

// ---- declarations / helper functions ----
sampler srcMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float4 pixel = tex2D(srcMap, uv).rgba;
pixel *= blitInfo.mScaleAndBias.xxxx;
pixel += blitInfo.mScaleAndBias.yyyy;
Current.color = pixel;
