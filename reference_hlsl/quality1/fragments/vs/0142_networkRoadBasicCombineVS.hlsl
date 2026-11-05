// Shader fragment  [VS slot 142]  networkRoadBasicCombineVS

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0>.xyz = float3( In.texcoord0.xy, 0.0f );
Current.texcoord<t1>.xyz = In.texcoord1.xyz;
Current.texcoord<t2>.xyz = worldPosition.xyz;
Current.texcoord<t3>.xyz = worldTangent;
