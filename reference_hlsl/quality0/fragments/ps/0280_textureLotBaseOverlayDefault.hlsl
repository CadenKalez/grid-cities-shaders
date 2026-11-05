// Shader fragment  [PS slot 280]  textureLotBaseOverlayDefault

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
addOverlay(overlayTexMask, overlayUntransformedTexCoord, 1.0, 0.5f, lotTexMask, overlayMask,
In.texcoord1, In.texcoord2, In.texcoord3,
In.texcoord4, In.texcoord5, In.texcoord6,
In.color); // first value, width of lines (for anti-aliasing). second value, test threshold.
Current.color.rgba = lotTexMask.rgba;
float3 bumpNormal = lerp(baseNormalMap.rgb, float3(0,0,1), overlayTexMask.a);
bumpNormal = float3(0,0,1); // do we care about the lotNormalMap if we can't transform it into the right space?  probably not.
