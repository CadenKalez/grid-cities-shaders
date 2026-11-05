// Shader fragment  [PS slot 462]  showAlphaAsDither

// ---- fragment body (spliced into the generated main()) ----
float4 colorIn = tex2D(Sampler<s0>, In.texcoord<t0>.xy);
const float kMaxDither = 0.7;
float ditherTarget = saturate(frac((In.vpos.x + In.vpos.y) * 0.5) * 2);
float ditherAmount = kMaxDither * colorIn.a;
Current.color = float4(ditherTarget, ditherTarget, ditherTarget, ditherAmount);
