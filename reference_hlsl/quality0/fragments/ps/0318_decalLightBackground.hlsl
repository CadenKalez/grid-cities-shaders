// Shader fragment  [PS slot 318]  decalLightBackground

// ---- fragment body (spliced into the generated main()) ----
float3 materialLightScale = decalMaterialInfo.x * 16.0 + 1;
float3 invMaterialLightRadius = decalMaterialInfo.y * 4.0;
float circleDist = saturate(1 - decalTexture.a * 256.0/200.0);
float circleZ = texturePosition.z * 0.5 + 0.5;  // distance from front of texture
//float circleZ = texturePosition.z;
circleZ *= length(decalWorldDirection) * invMaterialLightRadius;
float sphereDist = sqrt(circleDist*circleDist + circleZ*circleZ);
float lightScale = saturate(1 - sphereDist);
// apply light
float lightAmount = saturate(dot(normalize(decalWorldDirection), worldNormal)) * materialLightScale;
Current.color = float4(Current.color.rgb * lightScale * lightAmount, 0);
