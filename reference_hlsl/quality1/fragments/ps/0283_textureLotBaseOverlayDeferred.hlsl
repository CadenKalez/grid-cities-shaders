// Shader fragment  [PS slot 283]  textureLotBaseOverlayDeferred

// ---- uniform parameters ----
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

// ---- fragment body (spliced into the generated main()) ----
float3 lotNormal = In.texcoord1.xyz;
float3 lotTangent = In.texcoord2.xyz;
float4 borderWidths = In.color;
float overlayNormalIndex = baseTileIndex;
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
float specE = 8.0;
Current.color.w = specE/255.0;
Current.color1 = float4( bumpNormal.xyz * 0.5 + 0.5, overlayNormalIndex/16  );
