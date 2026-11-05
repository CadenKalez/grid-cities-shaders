// Shader fragment  [PS slot 124]  roadMaskDebugPS

// ---- fragment body (spliced into the generated main()) ----
float2 uv0 = In.texcoord<t0>.xy;
float3 uv1 = In.texcoord<t1>.xyz;
float maskColor = (uv0.x >= 0 && uv0.x <= 1 && uv0.y >= 0 && uv0.y <= 1) ? 1 : 0;
float zAcceleration = uv1.x;
float accelColor = 1 - saturate(zAcceleration * 20);
Current.color.rgb = float3(maskColor, accelColor, 1);
Current.color.rgb *= float3(0.7, 0.7, 0.7); 
Current.color.a = 0.3;
