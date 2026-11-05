// Shader fragment  [PS slot 387]  unitParticleSamplePS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- declarations / helper functions ----
sampler diffuseMap : register(s0);
sampler normalMap  : register(s1);
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
float2 screenUV = ( In.vpos.xy + float2( 0.5f, 0.5f ) ) * screenInfo.zw;
float2 uv       = In.texcoord<t0>.xy;
float4 diffuseMapSample = tex2D( diffuseMap, uv );
// We render pixels with alpha >= 0.9 into the deferred map,
// so compensate by making 0.9 be 'opaque'.
diffuseMapSample.a = saturate( diffuseMapSample.a * ( 1.0f / 0.9f ) );
float4 normalMapSample = tex2D( normalMap, uv );
float4 normalDepth = ImpostorUnpackNormalDepth( normalMapSample );
