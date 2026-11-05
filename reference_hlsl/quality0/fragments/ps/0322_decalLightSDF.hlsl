// Shader fragment  [PS slot 322]  decalLightSDF

// ---- fragment body (spliced into the generated main()) ----
float3 decalNUS = In.texcoord<t0>.xyz;
float materialLightScale = decalMaterialInfo.x * 16.0 + 0.25;
float sdfTextureLength = max(decalNUS.x, decalNUS.y);
float sphereHeight = decalNUS.z;
float hwRatio = sphereHeight * 0.5 / sdfTextureLength;
float zScale = 1;
if(hwRatio < 1)
{
hwRatio = 1;
zScale = 1 / hwRatio;
}
float circleZ = texturePosition.z;  // distance from center of texture
circleZ *= zScale;
float4 sdfDists = Current.color;
float kMaskCenter = 0.5;
float4 circleDists = saturate(1 - sdfDists * (1.0 / kMaskCenter)) * hwRatio;
float4 sphereDistsSqr = circleDists*circleDists + circleZ*circleZ;
float4 animEdge = max(animResults, 0.0);
float lerpXParam = sphereHeight * 0.5 / decalNUS.x;
float lerpYParam = sphereHeight * 0.5 / decalNUS.y;
float4 animRatio = lerp(float4(lerpXParam, lerpXParam, lerpXParam, lerpXParam), float4(lerpYParam, lerpYParam, lerpYParam, lerpYParam), useV.xyzw);
sphereDistsSqr += animEdge * animEdge * animRatio * 32;
float4 lightScales = saturate(1 - sqrt(sphereDistsSqr));
lightScales *= lightScales;
float3 lightColor = float3(0, 0, 0);
for(int i = 0; i < 3; ++i)
{
// apply light
lightColor[i] = materialLightScale * dot(decalMaterialData[i],lightScales);
}
// de-power
lightColor *= decalMaterialInfo.w;
Current.color.rgb = lightColor;
Current.color.a = 0;
