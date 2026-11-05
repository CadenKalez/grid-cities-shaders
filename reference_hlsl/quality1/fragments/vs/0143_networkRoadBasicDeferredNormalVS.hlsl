// Shader fragment  [VS slot 143]  networkRoadBasicDeferredNormalVS

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0>.xyz = float3( In.texcoord0.xy, 0.0f );
Current.texcoord<t1>.xyz = worldTangent;
Current.texcoord<t2>.xyz = worldNormal;
