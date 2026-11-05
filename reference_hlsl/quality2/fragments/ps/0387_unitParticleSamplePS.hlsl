// Shader fragment  [PS slot 387]  unitParticleSamplePS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- declarations / helper functions ----
sampler diffuseMap : register(s0);
sampler normalMap  : register(s1);
static const bool kPerPixelDepth = true;
float4 ImpostorUnpackNormalDepth(float4 normalMapSample)
{
float2 normalXY = normalMapSample.xy * 2 - 1;
float  xyLen = dot(normalXY, normalXY);
float  depthZSign = normalMapSample.z - 0.5;
float  pixDepth = abs(depthZSign * 2);
float  zSign = (depthZSign >= 0) ? 1 : -1;
float  normalZ = zSign * sqrt(1 - xyLen);
return float4(normalXY, normalZ, pixDepth);
}
float3 ImpostorPackNormalDepth(float3 normal, float pixelDepth)
{
normal = normalize(normal);
float zSign = (normal.z >= 0) ? 0.5 : -0.5;
return float3(normal.xy * 0.5 + 0.5, zSign*pixelDepth + 0.5);
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
