// Shader fragment  [VS slot 202]  vehicleOutputCombineVS

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = float4( worldPosition.xyz, 0.0f );
Current.texcoord<t1> = In.texcoord0.xyzw; 
Current.texcoord<t2> = float4( eyeDir, 0.0f );
Current.texcoord<t3> = miscParams;
