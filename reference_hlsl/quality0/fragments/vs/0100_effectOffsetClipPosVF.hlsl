// Shader fragment  [VS slot 100]  effectOffsetClipPosVF

// ---- fragment body (spliced into the generated main()) ----
{
clipPos.xyz += float3( axis.x, 0, 0 ) * (uv.x - 0.5);
clipPos.xyz += float3( 0, axis.y, 0 ) * (0.5 - uv.y);
}
