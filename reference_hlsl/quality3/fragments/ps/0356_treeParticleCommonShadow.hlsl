// Shader fragment  [PS slot 356]  treeParticleCommonShadow

// ---- declarations / helper functions ----
float4 EncodeDepth(float depth)
{
return float4(depth, frac(depth * 256), depth, 1);
}
sampler sourceTex : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseMapSample = tex2D(sourceTex, In.texcoord<t0>.xy);
clip(diffuseMapSample.a - 0.333);
// reconstruct the local depth
float2 projZ = In.texcoord<t2>.xy + In.texcoord<t2>.zw * diffuseMapSample.z;
float quaddepth = projZ.x / projZ.y;
quaddepth = saturate(quaddepth);
Current.depth = quaddepth;
Current.color = float4(1, 1, 1, 1);
