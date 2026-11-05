// Shader fragment  [VS slot 209]  copyLotUVsColorsNonInstanced

// ---- uniform parameters ----
uniform struct cLotInfo { float4 colorsR;float4 colorsG;float4 colorsB;float4 colorNormalsIdx;float4 borderWidthXYZW;float4 borderColorsR;float4 borderColorsG;float4 borderColorsB;float4 borderNormalsIdx;float4 baseTileUVMinMax;float4 overlayTileUVMinMax;float4 colorHeights;float4 borderHeights;} lotInfo;   // reg-meta 02d802d8000d000000000008
uniform float4 samplerInfo7;   // reg-meta 026502650001000000400000

// ---- fragment body (spliced into the generated main()) ----
Current.texcoord<t0> = In.texcoord0;
// offset the overlay by 1 pixel towards the front
Current.color1 = float4(lotInfo.overlayTileUVMinMax.xy+ float2(0*samplerInfo7.z,1*samplerInfo7.w), lotInfo.overlayTileUVMinMax.zw);
Current.texcoord<t1> = lotInfo.colorsR;
Current.texcoord<t2> = lotInfo.colorsG;
Current.texcoord<t3> = lotInfo.colorsB;
Current.texcoord<t4> = lotInfo.borderColorsR;
Current.texcoord<t5> = lotInfo.borderColorsG;
Current.texcoord<t6> = lotInfo.borderColorsB;
Current.color = lotInfo.borderWidthXYZW;
Current.texcoord<t7> = float4(In.position.xyz,lotInfo.baseTileUVMinMax.x+1.0/64.0);
