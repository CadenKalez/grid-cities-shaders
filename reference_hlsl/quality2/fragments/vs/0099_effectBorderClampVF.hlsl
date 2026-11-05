// Shader fragment  [VS slot 99]  effectBorderClampVF

// ---- fragment body (spliced into the generated main()) ----
{
clipPos.xy = clamp( clipPos.xy, -1, +1 );
}
