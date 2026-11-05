// Shader fragment  [PS slot 379]  simParticleShadowPS

// ---- declarations / helper functions ----
float4 EncodeDepth(float depth)
{
return float4(depth, frac(depth * 256), depth, 1);
}
sampler offscreenNormalTex : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float4 normalMapSample = tex2D(offscreenNormalTex, uv);
normalMapSample.rgb /= normalMapSample.a;
float4 normalDepth = ImpostorUnpackNormalDepth(normalMapSample);
// reconstruct the local depth
float2 projZ = In.texcoord<t1>.xy + In.texcoord<t1>.zw * normalDepth.w;
float  quaddepth = projZ.x / projZ.y;
quaddepth = saturate(quaddepth);
Current.color = EncodeDepth(quaddepth);
Current.color.a = normalMapSample.a;
Current.depth = quaddepth;
