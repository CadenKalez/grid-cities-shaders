// Shader fragment  [VS slot 283]  lineTexcoordOutputVF

// ---- fragment body (spliced into the generated main()) ----
float3  ray             = p1 - p0;
float3  rayNormal       = normalize( ray );
float   rayLen          = length( ray );
float   halfRayLen      = rayLen * 0.5f;
float4  level           = float4( Kd, Kd, Kd, Ks );
float endCapFallOffPercent = 0.65f; //if within this percentage from end of cylinder, we attenuate along primary axis
float denom             = 1.0 / ( radius2 - innerRadius2 );
float denomFalloff      = 1.0 / (halfRayLen - halfRayLen * endCapFallOffPercent);
Current.position        = hpos;
Current.texcoord<t0>    = float4( crwp.xyz, 0 );            //.w used by volumetric
Current.texcoord<t1>    = float4( dlColor.rgb, 1 ) * level; //.w used by volumetric
Current.texcoord<t2>    = float4( p0, radius );
Current.texcoord<t3>    = float4( volStrength, doubleSided, 0, innerRadius );
Current.texcoord<t4>    = float4( denom, radius2 * denom, denomFalloff, halfRayLen * denomFalloff );
Current.texcoord<t5>    = float4( rayNormal, vertexWorldPos.x );
Current.texcoord<t6>    = float4( hpos.xy * deferredInfo.xy + deferredInfo.zw * hpos.w, vertexWorldPos.y, hpos.w );
