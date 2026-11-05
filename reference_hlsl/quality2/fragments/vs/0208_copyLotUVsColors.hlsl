// Shader fragment  [VS slot 208]  copyLotUVsColors

// ---- uniform parameters ----
uniform struct cLotInstanceInfo { float4 colorsR;float4 colorsG;float4 colorsB;float4 colorNormalsIdx;float4 borderWidthXYZW;float4 borderColorsR;float4 borderColorsG;float4 borderColorsB;float4 borderNormalsIdx;float4 baseTileUVMinMax;float4 overlayTileUVMinMax;float4 colorHeights;float4 borderHeights;} lotInstanceInfo[14];   // reg-meta 02c802c800b6000000000008
uniform float4 samplerInfo7;   // reg-meta 026502650001000000400000

// ---- fragment body (spliced into the generated main()) ----
int lotsIndex3 = toInt(In.indices.x);
cLotInstanceInfo instanceInfo = lotInstanceInfo[lotsIndex3];
Current.texcoord<t0> = In.texcoord0;
// offset the overlay by 1 pixel towards the front
Current.color1 = float4(instanceInfo.overlayTileUVMinMax.xy+ float2(0*samplerInfo7.z,1*samplerInfo7.w), instanceInfo.overlayTileUVMinMax.zw);
Current.texcoord<t1> = instanceInfo.colorsR;
Current.texcoord<t2> = instanceInfo.colorsG;
Current.texcoord<t3> = instanceInfo.colorsB;
Current.texcoord<t4> = instanceInfo.borderColorsR;
Current.texcoord<t5> = instanceInfo.borderColorsG;
Current.texcoord<t6> = instanceInfo.borderColorsB;
Current.color = instanceInfo.borderWidthXYZW;
Current.texcoord<t7> = float4(In.position.xyz,instanceInfo.baseTileUVMinMax.x+1.0/64.0);
