// Shader fragment  [VS slot 207]  copyLotUVsNormals

// ---- uniform parameters ----
uniform struct cLotInstanceInfo { float4 colorsR;float4 colorsG;float4 colorsB;float4 colorNormalsIdx;float4 borderWidthXYZW;float4 borderColorsR;float4 borderColorsG;float4 borderColorsB;float4 borderNormalsIdx;float4 baseTileUVMinMax;float4 overlayTileUVMinMax;float4 colorHeights;float4 borderHeights;} lotInstanceInfo[14];   // reg-meta 02c802c800b6000000000008
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd
uniform float4 samplerInfo7;   // reg-meta 026502650001000000400000

// ---- fragment body (spliced into the generated main()) ----
int lotsIndex2 = toInt(In.indices.x);
int lotsIndexZ = toInt(In.indices.z);
cLotInstanceInfo instanceInfo = lotInstanceInfo[lotsIndex2];
Current.texcoord<t0> = In.texcoord0;
// offset the overlay by 1 pixel towards the front
Current.color1 = float4(instanceInfo.overlayTileUVMinMax.xy+ float2(0*samplerInfo7.z,1*samplerInfo7.w), instanceInfo.overlayTileUVMinMax.zw);
Current.texcoord<t1> = float4(0.0,0.0,1.0,clipPosition.w * nearFar.w * 255.0f);
Current.texcoord<t2> = float4(In.tangent.xyz,1.0-saturate(lotsIndexZ));
Current.texcoord<t3> = instanceInfo.colorNormalsIdx + 1.0/64.0;
Current.texcoord<t4> = instanceInfo.borderNormalsIdx + 1.0/64.0;
Current.texcoord<t5> = instanceInfo.colorHeights;
Current.texcoord<t6> = instanceInfo.borderHeights;
// to pack into Current.color we need to pack the depth from outputDepthVS (and then write ourselves instead of outputDepthPS)
Current.color = instanceInfo.borderWidthXYZW;
Current.texcoord<t7> = float4(topDownUV,In.position.z,instanceInfo.baseTileUVMinMax.x+1.0/64.0);
