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
// bump map based on neighbor heights
float leftHeight = 0;
float4 leftOverlay = tex2D(overlayTextureSampler, overlayTexCoord - float2(samplerInfo7.z*0.25,0.0));
float4 channelHeights = In.texcoord5;
float4 borderHeights = In.texcoord6;
overlayGetHeight(leftOverlay, overlayUntransformedTexCoord, 7.0, 0.5f, leftHeight, channelHeights, borderHeights, borderWidths);
float rightHeight = 0;
float4 rightOverlay = tex2D(overlayTextureSampler, overlayTexCoord + float2(samplerInfo7.z*0.25,0.0));
overlayGetHeight(rightOverlay, overlayUntransformedTexCoord, 7.0, 0.5f, rightHeight, channelHeights, borderHeights, borderWidths); // first value, width of lines (for anti-aliasing). second value, test threshold.
float upHeight = 0;
float4 upOverlay = tex2D(overlayTextureSampler, overlayTexCoord - float2(0.0,samplerInfo7.w*0.25));
overlayGetHeight(upOverlay, overlayUntransformedTexCoord, 7.0, 0.5f, upHeight, channelHeights, borderHeights, borderWidths); // first value, width of lines (for anti-aliasing). second value, test threshold.
float downHeight = 0;
float4 downOverlay = tex2D(overlayTextureSampler, overlayTexCoord + float2(0.0,samplerInfo7.w*0.25));
overlayGetHeight(downOverlay, overlayUntransformedTexCoord, 7.0, 0.5f, downHeight, channelHeights, borderHeights, borderWidths); // first value, width of lines (for anti-aliasing). second value, test threshold.
overlayNormal = normalize(overlayNormal+float3(leftHeight-rightHeight,downHeight-upHeight,0));
float3 bumpNormal = lerp(baseNormal.xyz, overlayNormal, overlayTexMask.a);
float alpha = max(lotTexMask.a, overlayTexMask.a);
bumpNormal = ApplyNormalMap(lotNormal, lotTangent, bumpNormal);
float specE = 8.0;
Current.color.w = specE/255.0;
Current.color1 = float4( bumpNormal.xyz * 0.5 + 0.5, overlayNormalIndex/16  );
