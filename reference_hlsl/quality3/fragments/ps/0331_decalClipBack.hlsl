// Shader fragment  [PS slot 331]  decalClipBack

// ---- fragment body (spliced into the generated main()) ----
{
float3 worldNormal = GetDeferredNormal(screenUV);
clip(dot(decalWorldDirection, worldNormal));
}
