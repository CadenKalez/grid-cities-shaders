// Shader fragment  [PS slot 225]  blitSingleChannelPS

// ---- uniform parameters ----
uniform struct { float4 mXYWH; float4 mScaleAndBias; } blitInfo;   // reg-meta 029702970002000000000008

// ---- declarations / helper functions ----
sampler srcMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float pixel = tex2D(srcMap, uv).x;
pixel *= blitInfo.mScaleAndBias.x;
pixel += blitInfo.mScaleAndBias.y;
Current.color = float4(pixel, 0, 0, 0);
