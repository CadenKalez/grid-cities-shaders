// Shader fragment  [PS slot 456]  writeGradientPS

// ---- fragment body (spliced into the generated main()) ----
float3 start = float3(0.0,0.0,0.0);
float3 end = float3(255.0/255.0,255.0/255.0,255.0/255.0);
float3 outColor = lerp(1.0f*start,1.0*end,In.texcoord0.x);
Current.color.rgba = float4(outColor,1);
