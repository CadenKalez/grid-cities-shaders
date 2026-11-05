// Shader fragment  [PS slot 21]  shShowNMap

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
float3 vertNormal = In.texcoord<t0>.xyz;
float3 normal = ApplyNormalMap(vertNormal, vertDS, nmapNormal);
Current.color.rgb = 0.5 * normal + 0.5;
