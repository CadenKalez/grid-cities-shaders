// Shader fragment  [PS slot 278]  lotTextureSamples

// ---- declarations / helper functions ----
uniform sampler overlayTextureSampler : register(s7);
uniform sampler lotTextureSampler     : register(s8);
uniform sampler lotNormalSampler      : register(s9);
uniform sampler overlayTintSampler    : register(s10);

// ---- fragment body (spliced into the generated main()) ----
float2 baseUV = In.texcoord0.zw;
float  baseTileIndex = floor(In.texcoord7.w);
float2 lotBaseUVMin = float2(frac(baseTileIndex * .25),floor(baseTileIndex * .25+0.01)*0.25);
float2 lotBaseUVMax = lotBaseUVMin + float2(0.25,0.25);
float2 lotTexCoord = lerp(lotBaseUVMin,lotBaseUVMax,frac(baseUV));
float2 uv_ddx = ddx(baseUV*abs(lotBaseUVMin-lotBaseUVMax));
float2 uv_ddy = ddy(baseUV*abs(lotBaseUVMin-lotBaseUVMax));
float4 lotTexMask = tex2Dgrad(lotTextureSampler, lotTexCoord, uv_ddx, uv_ddy);
float4 baseNormalMap = tex2Dgrad(lotNormalSampler,lotTexCoord, uv_ddx, uv_ddy);
float3 baseNormal = ( baseNormalMap.xyz * 2.0f ) - 0.9985f;
//float3 baseNormal;
//baseNormal.xy  = baseNormalMap.ga * 2.0f - 0.9985f;
//baseNormal.z   = sqrt( saturate( 1.0f - dot( baseNormal.xy, baseNormal.xy ) ) );
lotTexMask.a = baseGetAlpha(baseNormalMap, lotTexCoord, 4.0, 0.47f); 
float2 overlayTexCoord = lerp(In.color1.xy,In.color1.zw,saturate(In.texcoord0.xy));
float2 overlayUntransformedTexCoord = In.texcoord0.xy;
float4 overlayTexMask = tex2D(overlayTextureSampler, overlayTexCoord);
overlayTexMask = (abs(In.texcoord0.x - saturate(In.texcoord0.x)) > 0.0 || (In.texcoord0.y-saturate(In.texcoord0.y)) > 0.0)?float4(0.,0.,0.,0.):overlayTexMask;
float overlayMask = 0.0;
