// Material shader: building4Shader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (21 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 batchDatas[48];
uniform struct {float4 color;float4 data;} singleModelBatchData;
static const bool nonUniformScale = (false);
uniform float4 gameInfo;
static const int kNumPlanes = 4;
static const float4 kPlanes[kNumPlanes] = {
float4(normalize(float3(0,0.2,1)),1),
float4(normalize(float3(0,-0.2,1)),1),
float4(normalize(float3(0.2,0,1)),1),
float4(normalize(float3(-0.2,0,1)),1)
};
static const float3 kMove = float3(0,0,1);
static const float kOffs[kNumPlanes] = {
1.0/dot(kPlanes[0].xyz, kMove),
1.0/dot(kPlanes[1].xyz, kMove),
1.0/dot(kPlanes[2].xyz, kMove),
1.0/dot(kPlanes[3].xyz, kMove)
};
uniform float4 customClipPlane;
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
float3 rotateQ(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
float4 unpackAxisAnim(float4 rot)
{
// quat axis has values from 0 to 254 with 127.0 representing 0
const float2 kScales = float2(1.0 / 127.0, 1);
const float2 kOffsets = float2(-1,0);
float4 unpacked = rot * kScales.xxxy + kOffsets.xxxy;
// unpacked.xyz = normalize(unpacked.xyz);  // do we need this or are we good enough?
return unpacked;
}
float4 unpackTransAngle(float4 trans)
{
// maximum translation is +/-512, so in 16 bits that is 512 / 32768 = 1 / 64
// maximum rotation 4 rotations (angle is half for easy angle->quat, so slightly over 4*pi)
const float2 kScales = float2(1.0 / 64.0, 16.0 / 32768.0);
const float2 kOffsets = float2(0, 0);
float4 unpacked = trans * kScales.xxxy + kOffsets.xxxy;
return unpacked;
}
void animMorphRot(float4 axisAnim, float4 centerAngle, inout float3 pos, inout float3 normal, inout float3 tangent, float4 animTimes)
{
bool kCompressionEnabled = true;
if(kCompressionEnabled)
{
centerAngle = unpackTransAngle(centerAngle);
axisAnim = unpackAxisAnim(axisAnim);
}
// get anim time
int anim = int(axisAnim.w);
float t = animTimes[anim];
// verts with no anim are set to
//    rotAnim = (0,0,0,0)
//    centerAngle = (0,0,0,0)
// this turns into a translation by 0 * animTimes[0] which does nothing
// check trans vs rot
if(dot(axisAnim.xyz,axisAnim.xyz) < 0.5)
{
// translation
pos += centerAngle.xyz * t;
}
else
{
// multiply rotation by t
float halfTheta = -centerAngle.w * t;
float s,c;
sincos(halfTheta,s,c);
float4 q = float4(axisAnim.xyz * s, c);  // axis/angle -> quat
// translate position before rotation
pos -= centerAngle.xyz;
pos = rotateQ(q, pos);
pos += centerAngle.xyz;
// rotate normal and tangent
normal = rotateQ(q, normal);
tangent = rotateQ(q, tangent);
}
}
uniform float4 skinWeights;
uniform float4 SkinBones[(180)];
void SkinPosNormalTangent
(
int            numWeights,
int4           indices,
float4         boneWeights,
inout float4   position,
inout float3   normal,
inout float3   tangent
)
{
float4 row[3];
int index = toInt(indices.x);
row[0] = mul(boneWeights.x, SkinBones[index + 0]);
row[1] = mul(boneWeights.x, SkinBones[index + 1]);
row[2] = mul(boneWeights.x, SkinBones[index + 2]);
// this gets flattened, unless numWeights is variable
for (int i = 1; i < numWeights; i++)
{
index = toInt(indices[i]);
row[0] += mul(boneWeights[i], SkinBones[index + 0]);
row[1] += mul(boneWeights[i], SkinBones[index + 1]);
row[2] += mul(boneWeights[i], SkinBones[index + 2]);
}
// the compiler strips unused elements
float4 p = position;
position.x = dot(p, row[0]);
position.y = dot(p, row[1]);
position.z = dot(p, row[2]);
float3 n = normal;
normal.x = dot(n, row[0].xyz);
normal.y = dot(n, row[1].xyz);
normal.z = dot(n, row[2].xyz);
float3 t = tangent;
tangent.x = dot(t, row[0].xyz);
tangent.y = dot(t, row[1].xyz);
tangent.z = dot(t, row[2].xyz);
if (nonUniformScale)
{
// apply the inverse scale
float3 invScale2 = 1 / (row[0].xyz * row[0].xyz + row[1].xyz * row[1].xyz + row[2].xyz * row[2].xyz);
normal  *= invScale2;
tangent *= invScale2;
}
}
void SkinPosNormal(int numWeights, int4 indices, float4 weights, inout float4 position, inout float3 normal)
{
float3 dummy = float3(0, 0, 0);
SkinPosNormalTangent(numWeights, indices, weights, position, normal, dummy);
}
void SkinPos(int numWeights, int4 indices, float4 weights, inout float4 position)
{
float3 dummy = float3(0, 0, 0);
SkinPosNormalTangent(numWeights, indices, weights, position, dummy, dummy);
}
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
float3 quatrot(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
uniform float4x3 modelToWorld;
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
float3 batchedQuat(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
static const int kNumDeforms = 2;
static const float3 kDeformDir[kNumDeforms] = {
normalize(float3(1,1,0)),
normalize(float3(0,-1,1))
};
static const float3 kDeformUpAxis[kNumDeforms] = {
normalize(float3(1,0.1,0)),
normalize(float3(0.1,1,0))
};
static const float3 kDeformAxis[kNumDeforms] = {
normalize(cross(kDeformDir[0], kDeformUpAxis[0])),
normalize(cross(kDeformDir[1], kDeformUpAxis[1]))
};
static const float kDeformWavelength[kNumDeforms] = {
5,
6.5
};
static const float kDeformAmplitude[kNumDeforms] = {
.5, //0.5,
.8  //0.75,
};
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
uniform float4x3 modelToWorld;
uniform float4x3 worldToCamera;
uniform float4x3 modelToCamera;
static const int2  kPaletteSize = int2(256, 8);
static const float2 kPaletteInvSize = 1.0 / kPaletteSize;
// Convert from byte-represented color (0-1) to U value within texture
float BuildingPaletteVS(float palU)
{
// move to corner of 2x2 block
palU = palU * ((kPaletteSize.x - 1) * kPaletteInvSize.x);
return palU;
}
float BuildingPaletteVariationVS(int buildingType)
{
return buildingType * kPaletteInvSize.y;
}
float FastNoise(float3 seed)
{
seed *= float3(78.233, 12.9898, 43758.5453);
seed += float3(0.819 * 78.233, 0.819 * 12.9898, 0.819 * 43758.5453);
float random = frac(seed.z * frac(seed.x * frac(seed.y)));
return random;
}
static const float kNumTextureTiles  = 16;  
static const float kWorldTextureSize = 16;  
static const float kWorldToTextureRatio = kWorldTextureSize / kNumTextureTiles;
uniform float4 shCoeffs[9];
uniform float4 worldCameraDirection;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
const static float kSH_A1 = 2.0 / 3.0;
const static float kSH_A2 = 1.0 / 4.0;
const static float kSH_A3 = 0;
const static float kSH_A4 = -1.0 / 24.0;
const static float kDefaultGloss = 0.00;
const static float kGlossyMax    = 1.0; // threshold at which glossy maxes out
const static float kCelOutlineThreshold        = 0.25;
const static float kCelOutlineThresholdRange   = 0.075;
const static float kCelStrength                = 0.3;
const static float kSpecExponentMaxValue = 60.0;
const static bool kSaveInstructions = false;
void SHLighting
(
float3      normal,
float3      viewVector,
out float3  shColorDiff,
out float3  shColorSpec,
bool        translucency
)
{
float3 shColor;
float3 x0 = normal;
float3 x1 = x0 * x0;
float3 x2 = x0 * x0.yzx;
shColorDiff = shCoeffs[0].xyz;
shColorSpec = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
shColor  = shCoeffs[4].xyz  * x2.x;  // x * y
shColor += shCoeffs[5].xyz  * x2.y;  // y * z
shColor += shCoeffs[6].xyz  * (3 * x1.z - 1);
shColor += shCoeffs[7].xyz  * x2.z;  // z * x
shColor += shCoeffs[8].xyz  * (x1.x - x1.y);
shColor *= kSH_A2;
shColorDiff += shColor;
float3 reflectV;
if (translucency)
reflectV = -normal;
else
reflectV = reflect(viewVector, normal);
x0 = reflectV;
x1 = x0 * x0;
x2 = x0 * x0.yzx;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor += shCoeffs[4].xyz  * x2.x;  // x * y
shColor += shCoeffs[5].xyz  * x2.y;  // y * z
shColor += shCoeffs[6].xyz  * (3 * x1.z - 1);
shColor += shCoeffs[7].xyz  * x2.z;  // z * x
shColor += shCoeffs[8].xyz  * (x1.x - x1.y);
shColorSpec += shColor;
}
void SHDiffSpec9
(
float3      normal,
out float3  shColorDiff,
out float3  shColorSpec
)
{
SHLighting(normal, worldCameraDirection.xyz, shColorDiff, shColorSpec, false);
}
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 0000000000000000000000000000000000000000000000ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: batchInstanceDataVS   (cond 0102c10000000000000000000000000000000100000001ff)
    int meshBatchIndex5 = toInt(Current.indices.x);
    float4 rawInstanceInfo = batchDatas[meshBatchIndex5];
    float4 instanceColor = float4(1, 1, 1, rawInstanceInfo.w);
    float4 instanceData = rawInstanceInfo;
    // --- fragment: noInstanceDataVS   (cond 0000000000000000000000000000000000000100000001ff)
    float4 rawInstanceInfo = singleModelBatchData.data;
    float4 instanceColor = singleModelBatchData.color;
    float4 instanceData = singleModelBatchData.data;
    // --- fragment: skinScaleOff   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: deformRubbleVS   (cond 0502c102d0000000000000000000000000000200000002ff)
    {
    float planeOff = 0;
    int maxPlane = 0;
    float maxPlaneDist = dot(Current.position, float4(kPlanes[0].xyz, planeOff)) * kOffs[0];
    for(int i = 1; i < kNumPlanes; ++i)
    {
    float thisPlaneDist = dot(Current.position, float4(kPlanes[i].xyz, planeOff)) * kOffs[i];
    if(thisPlaneDist < maxPlaneDist)
    {
    maxPlane = i;
    maxPlaneDist = thisPlaneDist;
    }
    }
    Current.position.xyz += kMove * -max(maxPlaneDist,0.0) * 0.99;
    }
    // --- fragment: clipAgainstPlaneVSOnlyBatched   (cond 0502c102c5000000000000000000000000000200000002ff)
    {
    float4 clipPlane = customClipPlane;
    clipPlane.w = instanceData.w;
    float clipDist = dot(Current.position, clipPlane * 0.99);
    Current.position.xyz = Current.position.xyz - min(clipDist, 0) * customClipPlane.xyz;
    }
    // --- fragment:    (cond 0502c102cf000000000000000000000000000200000002ff)
    // --- fragment: morphRotationAnimVS   (cond 0102c10000000000000000000000000000000200000002ff)
    int buildingsIndex1 = toInt(Current.indices.x);
    float4 animTimes = batchInstanceInfo[buildingsIndex1].animdata;
    animMorphRot(In.binormal, In.weights, Current.position.xyz, Current.normal.xyz, Current.tangent.xyz, animTimes);
    // --- fragment: skinPositionNormalTangent   (cond 0100030000000000004000000000000000000200000002ff)
    SkinPosNormalTangent(int(skinWeights.x), Current.indices, Current.weights, Current.position, Current.normal.xyz, Current.tangent.xyz);
    modelPosition = Current.position;
    // --- fragment: worldSpaceBatchedNormalTangent   (cond 0102c10000000000000000000000000000000400000004ff)
    int meshBatchIndex2 = toInt(Current.indices.x);
    float3 worldNormal = normalize(quatrot(batchInstanceInfo[meshBatchIndex2].rotation, Current.normal.xyz));
    float3 worldTangent = normalize(quatrot(batchInstanceInfo[meshBatchIndex2].rotation, Current.tangent.xyz));
    float3 worldBinormal = cross( worldTangent, worldNormal );
    // --- fragment: worldSpaceNormalTangent   (cond 0000000000000000000000000000000000000400000004ff)
    float3 worldNormal  = mul(Current.normal.xyz,  make_float3x3(modelToWorld));
    float3 worldTangent = mul(Current.tangent.xyz, make_float3x3(modelToWorld));
    worldNormal  = normalize(worldNormal);
    worldTangent = normalize(worldTangent);
    float3 worldBinormal = cross(worldTangent, worldNormal);
    // --- fragment: toWorldSpaceBatched   (cond 0102c10000000000000000000000000000000000000000ff)
    int meshBatchIndex1 = toInt(Current.indices.x);
    Current.position.xyz *= batchInstanceInfo[meshBatchIndex1].translation.w;
    Current.position.xyz = batchedQuat(batchInstanceInfo[meshBatchIndex1].rotation, Current.position.xyz);
    Current.position.xyz += batchInstanceInfo[meshBatchIndex1].translation.xyz;
    // --- fragment: deformAbandonedVS   (cond 0102cf0000000000000000000000000000000800000008ff)
    {
    for(int i = 0; i < kNumDeforms; ++i)
    {
    float len = dot(Current.position.xyz, kDeformDir[i]);
    float amount = kDeformAmplitude[i] * sin(len / kDeformWavelength[i]);
    Current.position.xyz += amount * kDeformAxis[i];
    }
    }
    // --- fragment: modelPositionBatched   (cond 0102c10000000000000000000000000000002000000020ff)
    int meshBatchIndex3 = toInt(Current.indices.x);
    float3 modelPos = batchInstanceInfo[meshBatchIndex3].translation.xyz;
    // --- fragment: modelPosition   (cond 0000000000000000000000000000000000002000000020ff)
    float3 modelPos = mul(float4(0,0,0,1), modelToWorld).xyz;
    // --- fragment: building4SetupVS   (cond 0000000000000000000000000000000000000000000000ff)
    // should really use inverse transpose here but we use affine camera matrices so it doesn't matter
    float3 viewTangent = mul(float4(worldTangent,0), worldToCamera).xyz;
    float3 viewBinormal = mul(float4(worldBinormal,0), worldToCamera).xyz;
    float3 viewNormal = mul(float4(worldNormal,0), worldToCamera).xyz;
    float3 viewPos = mul(float4(Current.position.xyz,1), modelToCamera).xyz;
    float3x3 tangentSpace = float3x3(viewTangent, viewBinormal, viewNormal);
    float3 eyeDir = -mul(tangentSpace, viewPos);
    // unpack palettes
    float palU = BuildingPaletteVS(In.color.r);
    float palU2 = BuildingPaletteVS(In.color.g);
    // unpack interior data
    // texture location:
    // 4 bits size (1 to 16)
    // 4 bits index (0 to size-1)
    float interiorTexData = In.color.b * (16 * 255.0 / 256.0);
    int interiorSize = int(floor(interiorTexData)) + 1;
    int interiorSelection = int(floor(frac(interiorTexData) * 16));
    float interiorScale = 1.0f / interiorSize;
    float interiorOffset = interiorSelection * interiorScale;
    // random seed straight from data
    float interiorRandomSeed = In.color.a;
    // munge interior random seed by model position
    int2 quantizedModelPosition = int2(floor(modelPos.xy * 2));
    if(interiorRandomSeed < 0.5)
    interiorRandomSeed = FastNoise(float3(quantizedModelPosition, interiorRandomSeed));
    // unpack other texture coords
    float2 tileSize = In.texcoord1.xy;
    float2 tileOffset = In.texcoord1.zw;
    float2 tileSize2 = In.texcoord2.xy;
    float2 tileOffset2 = In.texcoord2.zw;
    float2 tilePadding = In.texcoord3.xy;
    float2 interiorRoomInvSize = In.texcoord3.zw;
    float2 uv = In.texcoord0.xy / abs(tileSize);
    float2 uv2 = In.texcoord0.zw / abs(tileSize2);
    uv2 += (tilePadding * .5);
    uv2 /= (1 + tilePadding);
    // --- fragment: building4ConstructionRubbleInteriorAndVariationSetupVS   (cond 0502c102c5000000000000000000000000004000000040ff)
    float3 interiorThresholds = float3(0,0,0); // force all interiors to dark
    float  buildingVariation = BuildingPaletteVariationVS(int(instanceData.r)); // instanceData.w holds construction/rubble param
    // --- fragment: building4ConstructionRubbleInteriorAndVariationSetupVS   (cond 0502c102d0000000000000000000000000004000000040ff)
    float3 interiorThresholds = float3(0,0,0); // force all interiors to dark
    float  buildingVariation = BuildingPaletteVariationVS(int(instanceData.r)); // instanceData.w holds construction/rubble param
    // --- fragment: building4InteriorAndVariationSetupVS   (cond 0000000000000000000000000000000000004000000040ff)
    float3 interiorThresholds = instanceData.rgb;
    float buildingVariation  = BuildingPaletteVariationVS(int(instanceData.w));
    // --- fragment: building4DefaultVS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 shDiffuse;
    float3 shSpec;
    SHDiffSpec9(worldNormal.xyz, shDiffuse, shSpec);
    //direct lighting from sun
    float sunMod = saturate(dot(sunSky.mSunDir.xyz, worldNormal));
    shDiffuse += sunMod * sunSky.mSunColor.rgb;
    Current.texcoord<t0> = float4(uv, uv2);
    Current.texcoord<t1> = float4(eyeDir, palU);
    Current.texcoord<t2> = float4(0, buildingVariation, interiorScale, palU2);
    Current.texcoord<t3> = float4(interiorRoomInvSize, tilePadding);
    Current.texcoord<t4> = float4(tileSize, tileOffset);
    Current.texcoord<t5> = float4(tileSize2, tileOffset2);
    Current.texcoord<t6> = float4(worldNormal, interiorRandomSeed);
    Current.texcoord<t7> = float4(shDiffuse, 0);
    Current.color       =  float4(interiorThresholds, interiorOffset);
    Current.color       =  floor(Current.color * 255) + 0.5; // deal with interpolator inaccuracy caused by perspective correction
    Current.color1      =  float4(shSpec, 0);
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (10 fragments; each may be conditionally enabled)
//==============================================================================
static const bool isAbandoned = true;
static const bool isAbandoned = false;
sampler tintMapSampler;
sampler normalMapSampler;
sampler shaderMapSampler;
sampler tintPaletteSampler;
sampler interiorMapSampler;
float4 GetDeferredLight( float2 screenUV )
{
return float4(0,0,0,0);
}
float3 GetDeferredNormal( float2 screenUV )
{
return float3(0,0,1);
}
float4 GetDeferredNormalAndSpec( float2 screenUV )
{
return float4(0,0,1,1);
}
const static float kSH_A1 = 2.0 / 3.0;
const static float kSH_A2 = 1.0 / 4.0;
const static float kSH_A3 = 0;
const static float kSH_A4 = -1.0 / 24.0;
const static float kDefaultGloss = 0.00;
const static float kGlossyMax    = 1.0; // threshold at which glossy maxes out
const static float kCelOutlineThreshold        = 0.25;
const static float kCelOutlineThresholdRange   = 0.075;
const static float kCelStrength                = 0.3;
const static float kSpecExponentMaxValue = 60.0;
const static bool kSaveInstructions = false;
uniform float4 worldCameraDirection;
static const float kReliefDepth = 0.1;
static const float kMaxConeRatio = 0.5;
float2 reliefMap(float2 tc, float3 ds, float4 tcxform, float flatDepth,
int ignore1, int ignore2,
float2 uv_ddx, float2 uv_ddy)
{
return tc;
}
static const int kConeSteps = 8;
static const int kBinarySteps = 2;
static const int kCullDistanceSq = 160000;
static const int kFlatLevelInt = 23;
static const float kFlatLevel = kFlatLevelInt / 255.0;
float2 interiorMap(float3 eye, float2 tc, float invMapDepth, float backSize, float dilation)
{
// shrink uvs by this much to avoid edge bleed near corners
const float kPadShrink = 0.9;
float3 eyeDir = eye;
eyeDir.z *= invMapDepth;
// Entrance position into the room
float3 pos = float3(tc, 0) * -2 + 1;
pos.z -= 1;
// clip to cube
float3 k = (sign(eyeDir) - pos) / eyeDir;
float t = min(k.x, min(k.y, k.z));
// target is now a point on the unit cube
float3 target = pos + t*eyeDir;
// do the perspective mapping
target.xy *= lerp(dilation, backSize, target.z);
return target.xy*-0.5 + 0.5;
}
float FastNoise(float3 seed)
{
seed *= float3(78.233, 12.9898, 43758.5453);
seed += float3(0.819 * 78.233, 0.819 * 12.9898, 0.819 * 43758.5453);
float random = frac(seed.z * frac(seed.x * frac(seed.y)));
return random;
}
static const float kBuildingInteriorMapInvDepth = 0.500000;
static const float kBuildingInteriorMapBackSize = 0.500000;
static const float kBuildingInteriorDilation = 0.900000;
static const bool kBilinearPaletteSample = true;
static const bool kOptimizedPaletteSample = true;
static const int2  kPaletteSize = int2(256, 8);
static const float2 kPaletteInvSize = 1.0 / kPaletteSize;
static const float kSurfacePalV = 1.0 - kPaletteInvSize.y;
void BuildingPaletteSamplePoint(float palU, float palV, float3 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(kOptimizedPaletteSample)
{
float subsample_u = tintValues.r;
float subsample_v = tintValues.g;
float r_g_b = tintValues.b * 2;
tintValues.b = subsample_u * r_g_b;
float r_g = r_g_b - tintValues.b;
tintValues.g = subsample_v * r_g;
tintValues.r = r_g - tintValues.g;
}
static const float2 kUvOffset_r = float2(0.25, 0.25) * kPaletteInvSize;
static const float2 kUvOffset_g = float2(0.25, 0.75) * kPaletteInvSize;
static const float2 kUvOffset_b = float2(0.75, 0.25) * kPaletteInvSize;
float4 uvsBase = float4(palU, palV, palU, kSurfacePalV);
float4 uvs_r = uvsBase + kUvOffset_r.xyxy;
float4 uvs_g = uvsBase + kUvOffset_g.xyxy;
float4 uvs_b = uvsBase + kUvOffset_b.xyxy;
// get tint matrices
float3x4 colorMatrix;
colorMatrix[0] = tex2D(tintPaletteSampler, uvs_r.xy);
colorMatrix[1] = tex2D(tintPaletteSampler, uvs_g.xy);
colorMatrix[2] = tex2D(tintPaletteSampler, uvs_b.xy);
colorValues = mul(tintValues.rgb, colorMatrix);
float3x4 surfaceMatrix;
surfaceMatrix[0] = tex2D(tintPaletteSampler, uvs_r.zw);
surfaceMatrix[1] = tex2D(tintPaletteSampler, uvs_g.zw);
surfaceMatrix[2] = tex2D(tintPaletteSampler, uvs_b.zw);
surfaceValues = mul(tintValues.rgb, surfaceMatrix);
}
void BuildingPaletteSampleBilerp(float palU, float palV, float3 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(!kOptimizedPaletteSample)
{
float r_g = tintValues.r + tintValues.g;
float r_g_b = (tintValues.r + tintValues.g + tintValues.b);
float subsample_u = r_g_b > 0 ? (tintValues.b / r_g_b) : 0.5;
float subsample_v = r_g > 0 ? (tintValues.g / r_g) : 0.5;
tintValues.r = subsample_u;
tintValues.g = subsample_v;
tintValues.b = saturate(r_g_b * 0.5);
}
static const float2 kSubsampleScale = kPaletteInvSize * 0.5;
static const float2 kSubsampleOffset = kPaletteInvSize * 0.25;
float2 subsample = tintValues.rg * kSubsampleScale + kSubsampleOffset;
float4 uvsBase = float4(palU, palV, palU, kSurfacePalV);
float4 adjustedUV = subsample.xyxy + uvsBase;
colorValues   = tex2D(tintPaletteSampler, adjustedUV.xy) * (tintValues.b * 2);
surfaceValues = tex2D(tintPaletteSampler, adjustedUV.zw) * (tintValues.b * 2);
}
void BuildingPaletteSample(float palU, float palV, float4 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(kBilinearPaletteSample)
{
BuildingPaletteSampleBilerp(palU, palV, tintValues.xyz, colorValues, surfaceValues);
}
else
{
BuildingPaletteSamplePoint(palU, palV, tintValues.xyz, colorValues, surfaceValues);
}
}
static const float kBuildingSpecOverdrive = 2.000000;
static const float kBuildingInteriorMapSelfLightMax = 16.000000;

void main_pixel()
{
    // --- fragment: setAbandoned   (cond 0102cf0000000000000000000000000000001000000010ff)
    // --- fragment: setAbandoned   (cond 0102d00000000000000000000000000000001000000010ff)
    // --- fragment: nonAbandoned   (cond 0000000000000000000000000000000000001000000010ff)
    // --- fragment: building4SamplersPS   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: deferredDiffuseDisabled   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: setupSHBasic   (cond 0000000000000000000000000000000000000000000000ff)
    float specStrength = 0;
    float specE = 1;
    float bumpFactor = 1;
    float gloss = kDefaultGloss;
    // --- fragment: building4UnpackDefaultPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 color1 = floor(In.color) * (1.0 / 255.0); // deal with interpolator inaccuracy caused by perspective correction
    float2 uv = In.texcoord<t0>.xy;
    float2 uv2 = In.texcoord<t0>.zw;
    float3 eyeDir = In.texcoord<t1>.xyz;
    float palU = In.texcoord<t1>.w;
    float3 shColorDiff = In.texcoord<t7>.xyz;
    float palU2 = In.texcoord<t2>.w;
    float3 shColorSpec = In.color1.xyz; // not used
    float buildingVariation = In.texcoord<t2>.y;
    float2 interiorSize = In.texcoord<t3>.xx;
    float2 interiorRoomInvSize = In.texcoord<t3>.xy;
    float2 tilePadding = In.texcoord<t3>.zw;
    float4 regionXform = In.texcoord<t4>;
    float4 regionXform2 = In.texcoord<t5>;
    float3 worldNormal = In.texcoord<t6>.xyz;
    float interiorRandomSeed = In.texcoord<t6>.w;
    float3 worldTangent = float3(0,1,0); // not used
    float3 interiorThresholds = color1.xyz;
    float interiorScale = In.texcoord<t2>.z;
    float interiorOffset = color1.w;
    float3 worldViewDirection = worldCameraDirection.xyz;
    // --- fragment: building4ClipAndReliefMapPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv_ddx = ddx(uv * regionXform.xy);
    float2 uv_ddy = ddy(uv * regionXform.xy);
    float2 baseUv = frac(uv) * regionXform.xy + regionXform.zw;
    float4 baseTintValues = tex2D(tintMapSampler, baseUv);
    Current.color.a = (baseTintValues.a - 0.5 < 0)?0:1;
    float3 reliefEyeDir = eyeDir;
    reliefEyeDir.xy /= abs(regionXform2.xy);  
    // handle padding and tiling
    uv2 = frac(uv2);
    uv2 = uv2 * (1 + tilePadding) - (tilePadding * .5);
    float2 reliefSrc = uv2;
    float distFromPixel = dot(eyeDir.xyz,eyeDir.xyz);
    float2 relief_tc;
    if( distFromPixel>kCullDistanceSq )
    relief_tc = reliefSrc;
    else
    relief_tc = reliefMap(reliefSrc, reliefEyeDir, regionXform2, kFlatLevel, kConeSteps, kBinarySteps, uv_ddx, uv_ddy);
    float4 tcBoundary = float4(0 - relief_tc.xy, relief_tc.xy - 1);
    float outsideTile = dot(saturate(tcBoundary), float4(1, 1, 1, 1));  // we really just care about this being > 0, the magnitude is irrelevant
    relief_tc = relief_tc * regionXform2.xy + regionXform2.zw;
    // --- fragment: building4InteriorMapPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 interiorUv = uv * regionXform.xy * interiorRoomInvSize;
    int2 interiorElem = int2(floor(interiorUv));
    float2 interiorSrcUv = frac(interiorUv);
    // and we need to adjust eyeDir to fit the room size
    float3 interiorEyeDir = eyeDir;
    interiorEyeDir *= interiorRoomInvSize.xyx;
    float2 interior_result_tc = interiorMap(interiorEyeDir, interiorSrcUv, kBuildingInteriorMapInvDepth, kBuildingInteriorMapBackSize, kBuildingInteriorDilation);
    float2 interior_tc = interior_result_tc * make_float2(interiorScale) + float2(0, interiorOffset);
    // Figure out what psuedo-random room we are in
    float roomId = FastNoise(float3(interiorElem, interiorRandomSeed));
    float roomVariation = floor(roomId * 4);  // choose between 4 possible room types
    roomId = frac(roomId * 4);
    // Choose an interior from the atlas based on the room id and the bin values
    float4 interior_edge = float4(step(interiorThresholds, make_float3(roomId)), roomVariation * 4); 
    float interior_offset = dot(interior_edge, float4(1, 1, 1, 1));
    interior_tc.x += interior_offset * interiorScale;
    // --- fragment: building4DefaultPS   (cond 0000000000000000000000000000000000000000000000ff)
    // sample textures
    half4 facadeTintValues = tex2D(tintMapSampler,    relief_tc,  uv_ddx, uv_ddy);
    half4 normalMapBase    = tex2D(normalMapSampler,  baseUv);
    half4 normalMapTop     = tex2D(normalMapSampler,  relief_tc);
    half4 shaderMapBase    = tex2D(shaderMapSampler,  baseUv);
    half4 shaderMapTop     = tex2D(shaderMapSampler,  relief_tc);
    half4 interiorMap = tex2D(interiorMapSampler, interior_tc);
    facadeTintValues.a = (outsideTile > 0) ? 0 : facadeTintValues.a;
    // Is normal lerp good enough?  Should renormalize?
    half4 shaderMapSampled = lerp(shaderMapBase, shaderMapTop, facadeTintValues.a);
    half4 tintBase;
    half4 specBase;
    BuildingPaletteSample(palU, buildingVariation, half4(baseTintValues.rgb, 0), tintBase, specBase);
    half4 tintTop;
    half4 specTop;
    BuildingPaletteSample(palU2, buildingVariation, half4(facadeTintValues.rgb, 0), tintTop, specTop);
    half4 tintResult = lerp(tintBase, tintTop, facadeTintValues.a);
    half4 specResult = lerp(specBase, specTop, facadeTintValues.a);
    // using interiorThresholds.z is a hack to turn the emissive off for unpowered buildings;
    // powered buildings always have .z = 1, unpowered/abandoned buildings have .z = 0.
    half artistEmissive = specResult.x * specResult.x * interiorThresholds.z;
    half3 tintColor = tintResult.rgb;
    half artistOpacity = shaderMapSampled.a;
    // apply lighting/ao
    half3 exteriorColor = tintColor * (shColorDiff + artistEmissive*256) + tintColor * shColorSpec;
    half3 interiorColor = interiorMap.rgb * (shColorDiff + interiorMap.aaa * kBuildingInteriorMapSelfLightMax + shColorSpec);
    // combine colors
    half3 finalColor = lerp(interiorColor, exteriorColor, artistOpacity);
    // output
    Current.color.rgb = finalColor;
}
