// Shader fragment  [PS slot 305]  lotToolPlopPreviewSetupPF

// ---- uniform parameters ----
uniform struct cLotInstanceInfo { float4 colorsR;float4 colorsG;float4 colorsB;float4 colorNormalsIdx;float4 borderWidthXYZW;float4 borderColorsR;float4 borderColorsG;float4 borderColorsB;float4 borderNormalsIdx;float4 baseTileUVMinMax;float4 overlayTileUVMinMax;float4 colorHeights;float4 borderHeights;} lotInstanceInfo[14];   // reg-meta 02c802c800b6000000000008

// ---- declarations / helper functions ----
sampler overlayTextureSampler : register(s0);
sampler lotTextureSampler : register(s1);

// ---- fragment body (spliced into the generated main()) ----
cLotInstanceInfo instanceInfo = lotInstanceInfo[0];
float tileIndex = instanceInfo.baseTileUVMinMax.x;
float2 lotBaseUVMin = float2(frac(tileIndex * .25),floor(tileIndex * .25)*0.25);
float2 lotBaseUVMax = lotBaseUVMin + float2(0.25,0.25);
float2 uv_ddx = ddx(In.texcoord<t0>.xy*abs(lotBaseUVMin-lotBaseUVMax));
float2 uv_ddy = ddy(In.texcoord<t0>.xy*abs(lotBaseUVMin-lotBaseUVMax));
float2 lotTexCoord = lerp(lotBaseUVMin,lotBaseUVMax,In.texcoord<t0>.xy);
float4 lotTexMask = tex2D(lotTextureSampler, lotTexCoord);
float2 vertexUV = In.texcoord<t0>.xy;
lotTexMask.a = 1.0f;
float2 overlayTexCoord = lerp(instanceInfo.overlayTileUVMinMax.xy, instanceInfo.overlayTileUVMinMax.zw, In.texcoord<t0>.xy);
float4 overlayTexMask = tex2D(overlayTextureSampler, overlayTexCoord);
