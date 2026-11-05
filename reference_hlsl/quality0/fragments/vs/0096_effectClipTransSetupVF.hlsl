// Shader fragment  [VS slot 96]  effectClipTransSetupVF

// ---- fragment body (spliced into the generated main()) ----
float2 uv = Current.color1.rg;
float scale = In.normal.w * 0.5;
{
Current.texcoord<t0> = Current.color1;
}
