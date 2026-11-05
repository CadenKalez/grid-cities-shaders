// Shader fragment  [PS slot 297]  textureLotBaseDeferred

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
float alpha = lotTexMask.a;
float3 bumpNormal = baseNormal.rgb;
bumpNormal = ApplyNormalMap(lotNormal, lotTangent, bumpNormal);
float specE = 8.0;
Current.color.w = specE/255.0;
Current.color1 = float4( bumpNormal.xyz * 0.5 + 0.5, baseTileIndex/16 );
