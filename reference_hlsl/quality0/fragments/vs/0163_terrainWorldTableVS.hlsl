// Shader fragment  [VS slot 163]  terrainWorldTableVS

// ---- uniform parameters ----
uniform struct { float4 mMisc; float4 mTessellation; float4 mMapping; float4 mMorph; float4x4 mMatrix; } terrainRegionInfoVS;   // reg-meta 029302930008000000000008

// ---- fragment body (spliced into the generated main()) ----
{
half4 worldPosition = mul(terrainRegionInfoVS.mMatrix, half4(Current.position.xy, -1024.0, 1));
Current.position = worldPosition;
half uvTileDiffuseTexture=128;
Current.texcoord<t0> = half4(0, 0, 0, 0);
Current.texcoord<t1> = half4(worldPosition.x/uvTileDiffuseTexture,worldPosition.y/uvTileDiffuseTexture, 0, 0);
Current.texcoord<t2> = worldPosition;
}
