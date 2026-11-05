// Shader fragment  [PS slot 257]  vehicleDeferredPS

// ---- declarations / helper functions ----
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}

// ---- fragment body (spliced into the generated main()) ----
float4 normalMap = tex2D( normalSampler, uv0 );
float3 normal;
normal.xy  = normalMap.ga * 2.0f - 0.9985f;
normal.z   = sqrt( saturate( 1.0f - dot( normal.xy, normal.xy ) ) );
float3 bumpNormal = ApplyNormalMap( worldNormal, worldTangent, normal );
