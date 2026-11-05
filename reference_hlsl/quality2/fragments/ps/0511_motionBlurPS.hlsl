// Shader fragment  [PS slot 511]  motionBlurPS

// ---- uniform parameters ----
uniform struct { float4 mPrevWorldToClipX; float4 mPrevWorldToClipY; float4 mPrevWorldToClipZ; float4 mPrevWorldToClipW; } motionBlurInfo;   // reg-meta 02d102d10004000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 temporalAA;   // reg-meta 02a102a10001000000000008

// ---- declarations / helper functions ----
extern uniform sampler colorTexture : register(s0);
extern uniform sampler depthTexture : register(s1);
static const float kBlurDistance = 0.04;

// ---- fragment body (spliced into the generated main()) ----
float2 screenUV = float2(In.texcoord<t0>.xy);
float3 farPoint  = In.texcoord<t1>.xyz;
float3 depthPixels = tex2D(depthTexture, screenUV).xyz;
float unitDepth = (depthPixels.x * 255.0 + depthPixels.y + depthPixels.z / 255.0) / 255.0;  
float3 viewPosition  = worldCameraPosition.xyz;
float3 viewDirection = normalize(farPoint);
float3 worldDistance = make_float3(unitDepth * nearFar.y);
float3 worldPos = viewPosition + farPoint * unitDepth;
float4x4 prevWorldToClip = float4x4(
motionBlurInfo.mPrevWorldToClipX,
motionBlurInfo.mPrevWorldToClipY,
motionBlurInfo.mPrevWorldToClipZ,
motionBlurInfo.mPrevWorldToClipW);
float4 tmp = mul(float4(worldPos, 1), prevWorldToClip);
float3 prevClipPos = tmp.xyz / tmp.w;
float2 prevUV = prevClipPos.xy * 0.5 + 0.5;
prevUV.y = saturate(1.0 - prevUV.y);
float2 uvStep = kBlurDistance * (prevUV - screenUV);
float2 dejitterOffset = float2(temporalAA.x, -temporalAA.y) * screenInfo.zw * 1.2;
float2 blurBaseUV = screenUV + dejitterOffset;
float4 pixel1 = tex2D(colorTexture, saturate(blurBaseUV + float2(uvStep * -3.0)));
float4 pixel2 = tex2D(colorTexture, saturate(blurBaseUV + float2(uvStep * -2.0)));
float4 pixel3 = tex2D(colorTexture, saturate(blurBaseUV + float2(uvStep * -1.0)));
float4 pixel4 = tex2D(colorTexture, saturate(blurBaseUV + float2(uvStep * 0.0)));
float4 pixel5 = tex2D(colorTexture, saturate(blurBaseUV + float2(uvStep * 1.0)));
float4 pixel6 = tex2D(colorTexture, saturate(blurBaseUV + float2(uvStep * 2.0)));
float4 pixel7 = tex2D(colorTexture, saturate(blurBaseUV + float2(uvStep * 3.0)));
float4 blurred = (pixel1+pixel2+pixel3+pixel4+pixel5+pixel6+pixel7) / 7.0;
Current.color = blurred;
