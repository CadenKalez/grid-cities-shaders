// Shader fragment  [VS slot 201]  vehicleOutputDeferredVS

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = float4( worldNormal, In.texcoord0.x );
Current.texcoord<t1> = float4( worldTangent, In.texcoord0.y );
Current.texcoord<t2> = float4( worldPosition.xyz, 0.0f );
