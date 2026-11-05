// Shader fragment  [PS slot 30]  impostorParticleDepthSpritePS

// ---- fragment body (spliced into the generated main()) ----
{
float2 projZ = In.texcoord<t0>.xy + In.texcoord<t0>.zw * normalDepth.w;
float quadDepth = projZ.x / projZ.y;

Current.depth = saturate(quadDepth);
}
