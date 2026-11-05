// Shader fragment  [PS slot 370]  simImpostorDepthFragments

// ---- declarations / helper functions ----
static const bool kPerPixelDepth = false;
float4 ImpostorUnpackNormalDepth(float4 normalMapSample)
{
return float4(normalMapSample.xyz * 2 - 1, 0);
}
float3 ImpostorPackNormalDepth(float3 normal, float pixelDepth)
{
return float3(normal * 0.5 + 0.5);
}

// ---- fragment body (spliced into the generated main()) ----

