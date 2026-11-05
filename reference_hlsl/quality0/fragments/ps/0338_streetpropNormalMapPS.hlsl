// Shader fragment  [PS slot 338]  streetpropNormalMapPS

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
float4 normalMap = tex2D( normalSampler, In.texcoord0.xy );
float3 normal;
normal.xy  = normalMap.ga * 2.0f - 0.9985f;
normal.z   = sqrt( saturate( 1.0f - dot( normal.xy, normal.xy ) ) );
float3 bumpNormal = ApplyNormalMap(In.texcoord<t0>.xyz, In.texcoord<t1>.xyz, normal.xyz);
