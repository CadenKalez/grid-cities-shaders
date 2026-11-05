// Shader fragment  [PS slot 294]  textureLotBaseDefault

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
float3 lotNormal = In.texcoord1.xyz;
float3 lotTangent = In.texcoord2.xyz;
float3 bumpNormal = baseNormal.rgb;
bumpNormal = ApplyNormalMap(lotNormal, lotTangent, bumpNormal);
Current.color.rgba = lotTexMask.rgba;
