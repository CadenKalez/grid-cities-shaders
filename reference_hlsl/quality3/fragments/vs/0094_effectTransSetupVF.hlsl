// Shader fragment  [VS slot 94]  effectTransSetupVF

// ---- fragment body (spliced into the generated main()) ----
float2 uv = Current.color1.rg;
float scale = In.normal.w;
{
Current.texcoord<t0> = Current.color1;
}
