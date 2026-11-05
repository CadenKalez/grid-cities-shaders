// Shader fragment  [PS slot 350]  impostorTreePS

// ---- fragment body (spliced into the generated main()) ----
Current.color.a = diffuseMap.a * saturate(100 * (aoMap.a - leavesFallen) + 1);
Current.color.rgb *= Current.color.a;  
float3 normalOutput = ImpostorPackNormalDepth(bumpNormal, clipPosition.z);
Current.color1.rgba = float4(normalOutput, 1.0);
