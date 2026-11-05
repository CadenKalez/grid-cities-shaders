// Shader fragment  [PS slot 373]  simImpostorShadow

// ---- fragment body (spliced into the generated main()) ----
float3 clipPosition = In.texcoord<t1>.xyz;
float3 vertexNormal = In.texcoord<t2>.xyz;
clip(float4(1 + clipPosition.xy, 1 - clipPosition.xy));
float3 outputNormalMap = ImpostorPackNormalDepth(vertexNormal.xyz, clipPosition.z);
Current.color.rgba = float4(outputNormalMap, 1);
