// Material shader: motionBlurShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 clipToWorld;
uniform float4 worldCameraPosition;

void main_vertex()
{
    // --- fragment: motionBlurQuadVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = In.texcoord<t0>.xyz;  
    float2 coords = In.texcoord0.xy * 2.0 - 1.0;
    coords.y = -coords.y;
    float4 farPoint  = mul(float4(coords, 1, 1), clipToWorld);
    Current.texcoord<t1> = farPoint.xyz / farPoint.w - worldCameraPosition.xyz;
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mPrevWorldToClipX; float4 mPrevWorldToClipY; float4 mPrevWorldToClipZ; float4 mPrevWorldToClipW; } motionBlurInfo;
uniform float4 worldCameraPosition;
uniform float4 nearFar;
uniform float4x4 worldToClip;
uniform float4 screenInfo;
uniform float4 temporalAA;
extern uniform sampler colorTexture : register(s0);
extern uniform sampler depthTexture : register(s1);
static const float kBlurDistance = 0.04;
extern uniform sampler prevFrameTexture : register(s2);

void main_pixel()
{
    // --- fragment: motionBlurPS   (cond 0000000000000000000000000000000000000000000000ff)
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
    // --- fragment: temporalAAPS   (cond 0102a10000000000000000000000000000000000000000ff)
    float kCamMoveDistanceFactor = 100.0;
    float kBlendFactor = .5; 
    float4 pixelCurrent = tex2D(colorTexture, screenUV);  
    float4 pixelPrev = tex2D(prevFrameTexture, screenUV);
    float colError = max(pixelCurrent.a, pixelPrev.a);
    float camMoveFactor = length(prevUV - screenUV) * kCamMoveDistanceFactor; // maybe use dist^2 here?
    float ssaaBlendFactor = saturate(max(camMoveFactor, colError));
    float4 ssaa = lerp(pixelCurrent, pixelPrev, kBlendFactor);
    float4 blurResult = lerp(ssaa, blurred, ssaaBlendFactor);
    Current.color = blurResult;
}
