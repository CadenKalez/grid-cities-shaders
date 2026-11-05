// Shader fragment  [VS slot 160]  grassSliceVS

// ---- fragment body (spliced into the generated main()) ----
{
float scale = 1.0;  
float3 localPosition = modelPosition.xyz;
float3 worldPosition = localPosition;
float3 worldNormal = In.normal.xyz;
Current.position = float4(worldPosition,1);
float alpha = modelPosition.w;  
Current.texcoord0 = float4(worldNormal, alpha);      
Current.texcoord1 = float4(worldPosition, 0);
Current.texcoord2 = float4(In.texcoord0.xyz, 0);  
}
