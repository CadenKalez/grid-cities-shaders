// Shader fragment  [PS slot 228]  blitMaxPS

// ---- uniform parameters ----
uniform struct { float4 mXYWH; float4 mScaleAndBias; } blitInfo;   // reg-meta 029702970002000000000008
uniform float4 samplerInfo0;   // reg-meta 025e025e0001000000400000

// ---- declarations / helper functions ----
sampler srcMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float2 st = samplerInfo0.zw * 0.5;  
float4 sample0 = tex2D(srcMap, uv + float2(-st.x, -st.y)).xyzw;
float4 sample1 = tex2D(srcMap, uv + float2(-st.x,  st.y)).xyzw;
float4 sample2 = tex2D(srcMap, uv + float2( st.x, -st.y)).xyzw;
float4 sample3 = tex2D(srcMap, uv + float2( st.x,  st.y)).xyzw;
float4 maxval = max(sample0, sample1);
maxval = max(maxval, sample2);
maxval = max(maxval, sample3);
Current.color = maxval;
