// Material shader: adaptiveDoFHorizontalNoDepthShader
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
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
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
uniform struct { float4 dofFocusPlane; float4 dofFocusDistances; float4 dofLerpScale;float4 dofLerpBias;} tiltShiftDOFInfo;
extern uniform sampler color : register(s0);

void main_pixel()
{
    // --- fragment: adaptiveDoFSharedPS   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: performAdaptiveDoFHorizontalPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 texOffset = float2(renderTargetInfo0.z,0);
    // --- fragment: performAdaptiveDoFNoDepthPS   (cond 0000000000000000000000000000000000000000000000ff)
    // Diameter of max CoC
    float maxCoC = tiltShiftDOFInfo.dofFocusPlane.x * maxCoCSize * 0.5f;
    float4 centerColor = tex2D(color, In.texcoord0.xy);
    float centerCoCRadius = max(centerColor.a * maxCoC, epsilon.x);
    float accumWeights = gaussianWeights[0] / (centerCoCRadius * centerCoCRadius);
    float4 accum = centerColor * accumWeights;
    for (int i = 1; i <= sampleRadius; i+=2)
    {
    float4 finalOffset = float4(texOffset * i, texOffset * (i+1));
    float4 texcoordLeft = In.texcoord0.xyxy - finalOffset;
    float4 texcoordRight = In.texcoord0.xyxy + finalOffset;
    // Alpha channel stores pixel's CoC from half-res downsample
    float4 colorLeft = tex2D(color, texcoordLeft.xy);
    float4 colorFarLeft = tex2D(color, texcoordLeft.zw);
    float4 colorRight = tex2D(color, texcoordRight.xy);
    float4 colorFarRight = tex2D(color, texcoordRight.zw);
    float4 radii = float4(colorLeft.a, colorFarLeft.a, colorRight.a, colorFarRight.a) * maxCoC;
    // Compute overlap weight
    float4 overlapWeights = radii - float4(i, i, i, i);
    overlapWeights = lesser_than(radii, i) ? float4(0, 0, 0, 0) : overlapWeights;
    overlapWeights = is_greater_equal(radii, i + 1) ? float4(1, 1, 1, 1) : overlapWeights;
    // Compute intensity weight
    float4 intensityWeights = 1.0f / max((radii * radii), epsilon);
    // Compute leakage weight
    float4 leakageWeights = saturate(radii / centerCoCRadius);
    // Final weight
    float4 weights = overlapWeights * intensityWeights * leakageWeights;
    weights.xz *= gaussianWeights[i];
    weights.yw *= gaussianWeights[i + 1];
    accum += colorLeft * weights.x +
    colorFarLeft * weights.y +
    colorRight * weights.z +
    colorFarRight * weights.w;
    accumWeights += dot(weights, float4(1,1,1,1));
    }
    accum /= accumWeights;
    Current.color = float4(accum.rgb, centerColor.a);
    // 36 bytes of texture data sampled per pixel
}
