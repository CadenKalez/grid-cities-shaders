// Shader fragment  [PS slot 110]  networkRoadBasicDeferredNormalPS

// ---- declarations / helper functions ----
sampler2D diffuseSampler        : register(s0);
sampler2D normalMapSampler      : register(s1);
sampler2D specSampler           : register(s2);
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}

// ---- fragment body (spliced into the generated main()) ----
float2 baseUV       = In.texcoord<t0>.xy;
float3 worldTangent = In.texcoord<t1>.xyz;
float3 worldNormal  = In.texcoord<t2>.xyz;
float4 diffuseMap = tex2D( diffuseSampler, baseUV ).rgba;
clip( diffuseMap.a - 0.75f );
float4 normalMap = tex2D( normalMapSampler, baseUV );
float3 bumpNormal;
bumpNormal.xy = normalMap.ga * 2.0f - 0.9985f;
bumpNormal.z  = sqrt( saturate( 1.0f - dot( bumpNormal.xy, bumpNormal.xy ) ) );
float3 specMap = tex2D( specSampler, baseUV ).rgb;
float  specE   = ( specMap.r * specMap.r * specMap.r + 1.0f / 1024.0f ) * 1024.0f;
bumpNormal = ApplyNormalMap( worldNormal, worldTangent, bumpNormal );
