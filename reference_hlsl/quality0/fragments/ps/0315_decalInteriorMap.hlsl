// Shader fragment  [PS slot 315]  decalInteriorMap

// ---- declarations / helper functions ----
static const float kInteriorMapSelfLightMax = 16.000000;

// ---- fragment body (spliced into the generated main()) ----
const float kSunContributionAmount = decalMaterialData[0].x;
const float kLightAmount = decalMaterialData[0].y;
float3 textureFloatPosition = In.texcoord<t0>.xyz;
float2 interiorUv = lerp(textureFloatPosition.xy, textureFloatPosition.xy * 0.5, textureFloatPosition.z * 0.5 + 0.5);
interiorUv = interiorUv * -0.5 + 0.5;
interiorUv = interiorUv * texXform.xy + texXform.zw;
float sunMod = saturate(dot(sunSky.mSunDir.xyz, bumpNormal.xyz));
float3 sunColor = sunMod * sunSky.mSunColor.rgb * shadow;
shColorDiff -= sunColor;
shColorDiff *= kLightAmount;
shColorSpec *= kLightAmount;
shColorDiff += sunColor * kSunContributionAmount;
float4 interiorTexture = tex2D(Sampler<s0>, interiorUv);
float3 interiorTextureLit = interiorTexture.rgb * (shColorDiff + shColorSpec + spec + interiorTexture.a * kInteriorMapSelfLightMax);
Current.color.rgb = lerp(Current.color.rgb, interiorTextureLit, saturate(decalTexture.a * 2 - 1));
Current.color.a = saturate(decalTexture.a * 2);
