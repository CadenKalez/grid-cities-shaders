// Shader fragment  [PS slot 467]  adaptiveDoFSharedPS

// ---- uniform parameters ----
uniform struct { float4 dofFocusPlane; float4 dofFocusDistances; float4 dofLerpScale;float4 dofLerpBias;} tiltShiftDOFInfo;   // reg-meta 02a502a50004000000000008
uniform struct { float4 mTargetSizes; float4 mViewportSizes; float4 mNearFar;} cameraParams;   // reg-meta 022202220003000000004000
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000

// ---- declarations / helper functions ----
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

// ---- fragment body (spliced into the generated main()) ----

