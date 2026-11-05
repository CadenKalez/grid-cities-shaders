// Shader fragment  [VS slot 275]  spotTexcoordOutputVF

// ---- fragment body (spliced into the generated main()) ----
float denomFalloff      = 1.0 / ( falloffDist - falloffStart + 0.0001 );
float denomCone         = 1.0 / ( radius - innerRadius + 0.0001 );
float4 level            = float4( Kd, Kd, Kd, Ks );
Current.position        = hpos;
Current.texcoord<t0>    = float4( hpos.xy * deferredInfo.xy + deferredInfo.zw * hpos.w, volStrength, hpos.w );
Current.texcoord<t1>    = float4( dlColor.rgb, 1.0 ) * level;
Current.texcoord<t2>    = float4( crwpFarClip.xyz, doubleSided );
Current.texcoord<t3>    = float4( crwpLightPos, radius );
Current.texcoord<t4>    = float4( ldir, innerRadius );
Current.texcoord<t5>    = float4( denomFalloff, falloffDist * denomFalloff, denomCone, radius * denomCone );
Current.texcoord<t6>    = float4( vertexWorldPos.xy, 0, 0); //.zw is used by volumetric when it is enabled.
