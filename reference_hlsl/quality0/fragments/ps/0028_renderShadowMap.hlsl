// Shader fragment  [PS slot 28]  renderShadowMap

// ---- declarations / helper functions ----
float4 EncodeDepth(float depth)
{
return float4(depth, frac(depth * 256), depth, 1);
}

// ---- fragment body (spliced into the generated main()) ----
float depth = saturate(In.texcoord<t0>.x);
Current.color = EncodeDepth(depth);
