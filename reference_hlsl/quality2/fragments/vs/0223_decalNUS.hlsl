// Shader fragment  [VS slot 223]  decalNUS

// ---- fragment body (spliced into the generated main()) ----
{
float3 NUSTextureSqr;
NUSTextureSqr.x = dot(modelToTexture[0].xyz, modelToTexture[0].xyz);
NUSTextureSqr.y = dot(modelToTexture[1].xyz, modelToTexture[1].xyz);
NUSTextureSqr.z = dot(modelToTexture[2].xyz, modelToTexture[2].xyz);
float uniformSqr = dot(modelToWorld[0].xyz, modelToWorld[0].xyz);
Current.texcoord<t0>.xyz = sqrt(NUSTextureSqr * uniformSqr);
}
