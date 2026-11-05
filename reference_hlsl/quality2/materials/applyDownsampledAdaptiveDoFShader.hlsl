// Material shader: applyDownsampledAdaptiveDoFShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 dofFocusPlane; float4 dofFocusDistances; float4 dofLerpScale;float4 dofLerpBias;} tiltShiftDOFInfo;
uniform struct { float4 mTargetSizes; float4 mViewportSizes; float4 mNearFar;} cameraParams;
uniform float4 renderTargetInfo0;
static const float maxCoCSize = 0.005f; // Percentage of min(w,h) of render target
static const int numSamples = 9;
static const int sampleRadius = numSamples / 2;
static const float4 epsilon = float4(1e-12, 1e-12, 1e-12, 1e-12);
static const float gaussianWeights[5] = {0.29937241, 0.22597815, 0.09719199, 0.02381792, 0.00332573};
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
// Returns normalized CoC value that needs to be scaled to current max CoC dimension
// and the offset of the pixel from the focal plane
float computePixelCoC(float2 texcoord)
{
float4 focalDepths = tiltShiftDOFInfo.dofFocusDistances;
float depth = UnpackDepth(tex2D(depthMap, texcoord));
float linearDepth = depth * cameraParams.mNearFar.y;
float offsetFromFocalPlane = linearDepth - tiltShiftDOFInfo.dofFocusPlane.w; // signed distance
float nearCoC = saturate(focalDepths.x * offsetFromFocalPlane + focalDepths.y);
float farCoC = saturate(focalDepths.z * offsetFromFocalPlane + focalDepths.w);
return max(nearCoC, farCoC);
}
float4 computePixelCoC4(float4 texcoordLeft, float4 texcoordRight)
{
float4 focalDepths = tiltShiftDOFInfo.dofFocusDistances;
float4 depth;
depth.x = UnpackDepth(tex2D(depthMap, texcoordLeft.xy));
depth.y = UnpackDepth(tex2D(depthMap, texcoordLeft.zw));
depth.z = UnpackDepth(tex2D(depthMap, texcoordRight.xy));
depth.w = UnpackDepth(tex2D(depthMap, texcoordRight.zw));
float4 linearDepth = depth * cameraParams.mNearFar.yyyy;
float4 offsetFromFocalPlane = linearDepth - tiltShiftDOFInfo.dofFocusPlane.wwww; // signed distance
float4 nearCoC = saturate(focalDepths.xxxx * offsetFromFocalPlane + focalDepths.yyyy);
float4 farCoC = saturate(focalDepths.zzzz * offsetFromFocalPlane + focalDepths.wwww);
return max(nearCoC, farCoC);
}
uniform float4 renderTargetInfo0;
extern uniform sampler adaptiveDoF : register(s0);
extern uniform sampler adaptiveDoF2 : register(s14);

void main_pixel()
{
    // --- fragment: adaptiveDoFSharedPS   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: applyDownsampledAdaptiveDoFPS   (cond 0000000000000000000000000000000000000000000000ff)
    static const float2 denom = float2(1.0f / 0.33f, 1.0f / (1.0f - 0.33f));
    float currCoC = computePixelCoC(In.texcoord0.xy);
    // Perform 3-way linear blend between in-focus, out-of-focus, and super-out-of-focus.
    // In-focus blending happens via the final alpha blend with the color buffer.
    // CoC between 0.33 - 1.0 lerps between out-of-focus and super-out-of-focus
    float2 blendWeight = float2(min(currCoC, 0.33f), saturate(currCoC - 0.33f)) * denom;
    float4 outOfFocus = tex2D(adaptiveDoF, In.texcoord0.xy);
    float4 superOutOfFocus = tex2D(adaptiveDoF2, In.texcoord0.xy);
    // Alpha channel stores calculated CoC for that pixel. Due to downsampling, the CoCs
    // need not match so we bias towards the higher res blur if there is a discrepancy
    // between CoC.
    blendWeight.y = saturate(blendWeight.y - (outOfFocus.a - superOutOfFocus.a) * 2.0f);
    float4 finalColor = lerp(outOfFocus, superOutOfFocus, blendWeight.y);
    Current.color = finalColor * blendWeight.x;
    Current.color.a = blendWeight.x;
    // 12 bytes of texture data sampled per pixel
}
