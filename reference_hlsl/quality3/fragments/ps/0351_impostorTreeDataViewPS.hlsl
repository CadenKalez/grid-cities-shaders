// Shader fragment  [PS slot 351]  impostorTreeDataViewPS

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
Current.color.a = diffuseMap.a * saturate(100 * (aoMap.a - leavesFallen) + 1);
Current.color.rgb *= Current.color.a;  
float3 normalOutput = ImpostorPackNormalDepth(bumpNormal, clipPosition.z);
Current.color1.rgba = float4(normalOutput, 1.0);
