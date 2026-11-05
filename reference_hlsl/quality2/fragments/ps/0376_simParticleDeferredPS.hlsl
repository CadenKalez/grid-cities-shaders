// Shader fragment  [PS slot 376]  simParticleDeferredPS

// ---- declarations / helper functions ----
sampler offscreenNormalTex : register(s1);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float2 quadCorner = In.texcoord<t0>.zw;
float outputDepth = In.texcoord<t1>.x;
float4 normalMapSample = tex2D(offscreenNormalTex, uv);
clip(normalMapSample.a - 0.9);
normalMapSample.rgb /= normalMapSample.a;
float4 normalDepth = ImpostorUnpackNormalDepth(normalMapSample);
if(kPerPixelDepth)
outputDepth = saturate(outputDepth + normalDepth.w * In.texcoord<t1>.y);
Current.color = float4(floor(outputDepth * 255.0) / 255.0, frac(outputDepth * 255.0),  frac(frac(outputDepth * 255.0)*255.0), 8.0/255);
Current.color1 = float4(normalDepth.xyz * 0.5 + 0.5, 1);
