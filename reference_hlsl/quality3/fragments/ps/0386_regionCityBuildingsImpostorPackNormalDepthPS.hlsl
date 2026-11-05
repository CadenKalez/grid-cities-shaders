// Shader fragment  [PS slot 386]  regionCityBuildingsImpostorPackNormalDepthPS

// ---- declarations / helper functions ----
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
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
float4 normalMapBase = tex2Dgrad( normalMapSampler, baseUv,    uv_ddx1, uv_ddy1 );
float4 normalMapTop  = tex2Dgrad( normalMapSampler, relief_tc, uv_ddx2, uv_ddy2 );
// Is normal lerp good enough?  Should renormalize?
float4 normalMapSampled = lerp( normalMapBase, normalMapTop, facadeTintValues.a );
// unpack
float3 normalMap = normalMapSampled.rgb;
float3 nmapNormal = normalMap.rgb * 2 - 0.9985;
float3 bumpNormal = ApplyNormalMap( worldNormal, worldTangent, nmapNormal );
float3 normalOutput = ImpostorPackNormalDepth( bumpNormal, clipPosition.w );
Current.color1.rgba = float4( normalOutput, interiorLighting * poweredState );
