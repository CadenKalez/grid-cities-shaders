// Shader fragment  [PS slot 289]  textureLotOverlayDeferred

// ---- uniform parameters ----
uniform float4 samplerInfo4;   // reg-meta 026202620001000000400000
uniform float4 samplerInfo7;   // reg-meta 026502650001000000400000

// ---- declarations / helper functions ----
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}
uniform sampler topDownTerrainNormals  : register(s3);  
static const float kCreaseStrength = .3;
static const float kCreaseStart    = 0.8;

// ---- fragment body (spliced into the generated main()) ----
float3 lotNormal = In.texcoord1.xyz;
float3 lotTangent = In.texcoord2.xyz;
lotTexMask = float4(0, 0, 0, 0);
baseNormal.xyz = float3(0, 0, 1);
float4 borderWidths = In.color;
float overlayNormalIndex = 0;
overlayTexMask.a = overlayGetAlphaAndIndex(overlayTexMask, overlayUntransformedTexCoord, 1.0, 0.5f, overlayNormalIndex,
In.texcoord3, In.texcoord4,
borderWidths).x; 
float2 overlayNormalUVMin = float2(frac(overlayNormalIndex * .25),floor(overlayNormalIndex * .25)*0.25);
float2 overlayNormalUVMax = overlayNormalUVMin + float2(0.25,0.25);
float2 overlayNormalCoord = lerp(overlayNormalUVMin,overlayNormalUVMax,frac(baseUV));
float3 overlayNormal = tex2D(lotNormalSampler,overlayNormalCoord).xyz;
overlayNormal.xyz = ( overlayNormal.xyz * 2.0f ) - 0.9985f;
float3 bumpNormal = lerp(baseNormal.xyz, overlayNormal, overlayTexMask.a);
float alpha = max(lotTexMask.a, overlayTexMask.a);
bumpNormal = ApplyNormalMap(lotNormal, lotTangent, bumpNormal);
float2 heightMapUV = In.texcoord7.xy;
float4 normalMapSample = tex2D(topDownTerrainNormals, heightMapUV).xyzw;  
float3 terrainNormal = normalMapSample.xyz * 2.0 - 1.0;  
terrainNormal.z *= (1 - kCreaseStrength);
if (terrainNormal.z > (1 - kCreaseStrength) * kCreaseStart)
terrainNormal.z += kCreaseStrength;
bumpNormal = lerp(terrainNormal, bumpNormal, overlayTexMask.a);
float specE = 8.0;
Current.color.w = specE/255.0;
Current.color1 = float4( bumpNormal.xyz * 0.5 + 0.5, overlayNormalIndex/16 );
