// Shader fragment  [PS slot 353]  treeParticleCommonSamplePS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 samplerInfo0;   // reg-meta 025e025e0001000000400000
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- declarations / helper functions ----
static const float kMipLevelClamp = 5.0f;
sampler offscreenNormalTex : register(s1);
sampler sourceTex          : register(s0);
float CalcMipLevel( float2 uv )
{
float2 dx = ddx( uv );
float2 dy = ddy( uv );
float d = max( dot( dx, dx ), dot( dy, dy ) );
return 0.5f * log2( d );
}
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
float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
float2 uv       = In.texcoord<t0>.xy;
float  type     = In.texcoord<t0>.z;
float  mipLevel = 0.0f;
float4 normalDepth = float4(0.0f, 0.0f, 0.0f, 0.0f);
mipLevel = CalcMipLevel(uv * samplerInfo0.xy);
mipLevel = min(mipLevel, kMipLevelClamp);
float4 diffuseMapSample = tex2Dlod(sourceTex, float4(uv, 0, mipLevel));
diffuseMapSample.a = saturate(diffuseMapSample.a * (1.0 / 0.9));
diffuseMapSample.rgb /= diffuseMapSample.a;
float4 normalMapSample = tex2Dlod(offscreenNormalTex, float4(uv, 0, mipLevel));
normalMapSample.z /= normalMapSample.a;
normalDepth = ImpostorUnpackNormalDepth(normalMapSample);
