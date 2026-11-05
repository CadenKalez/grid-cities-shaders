// Shader fragment  [VS slot 191]  building4CombineVS

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = float4(uv, uv2);
Current.texcoord<t1> = float4(eyeDir, palU);
Current.texcoord<t2> = float4(interiorRoomInvSize, buildingVariation, palU2);
Current.texcoord<t3> = float4(interiorScale, interiorOffset, tilePadding.xy);
Current.texcoord<t4> = float4(tileSize, tileOffset);
Current.texcoord<t5> = float4(tileSize2, tileOffset2);
Current.color        = float4(interiorThresholds, interiorRandomSeed);
Current.color        = floor(Current.color * 255) + 0.5; // deal with interpolator inaccuracy caused by perspective correction
