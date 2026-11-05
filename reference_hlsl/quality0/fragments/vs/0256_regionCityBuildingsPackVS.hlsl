// Shader fragment  [VS slot 256]  regionCityBuildingsPackVS

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = float4( uv, uv2 );
Current.texcoord<t1> = float4( tileSize, tileOffset );
Current.texcoord<t2> = float4( tileSize2, tileOffset2 );
Current.texcoord<t3> = float4( tilePadding, palU, palU2 );
Current.texcoord<t4> = float4( clipPosition.xyz, cameraSpacePosition.z );
Current.texcoord<t5> = float4( interiorRoomInvSize, interiorLightTime, poweredState );
