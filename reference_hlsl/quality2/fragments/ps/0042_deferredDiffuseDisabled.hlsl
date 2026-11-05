// Shader fragment  [PS slot 42]  deferredDiffuseDisabled

// ---- declarations / helper functions ----
float4 GetDeferredLight( float2 screenUV )
{
return float4(0,0,0,0);
}
float3 GetDeferredNormal( float2 screenUV )
{
return float3(0,0,1);
}
float4 GetDeferredNormalAndSpec( float2 screenUV )
{
return float4(0,0,1,1);
}

// ---- fragment body (spliced into the generated main()) ----

