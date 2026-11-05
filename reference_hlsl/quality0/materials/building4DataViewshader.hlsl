// Material shader: building4DataViewshader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (20 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 batchColors[48];
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
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;
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
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 0000000000000000000000000000000000000000000000ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: batchInstanceColorVS   (cond 0102c10000000000000000000000000000000100000001ff)
    int meshBatchIndex4 = toInt(Current.indices.x);
    float4 rawInstanceInfo = batchColors[meshBatchIndex4];
    float4 instanceColor = rawInstanceInfo;
    float4 instanceData = float4(1, 1, 1, rawInstanceInfo.w);
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
    // --- fragment: setupDataViewBatchedVS   (cond 0102c10000000000000000000000000000000800000008ff)
    Current.color = float4( pow(instanceColor.xyz, float3(2.2, 2.2, 2.2)), 1 );
    // --- fragment: setupDataViewInstancedVS   (cond 0000000000000000000000000000000000000800000008ff)
    Current.color = float4( pow(globalDataView.baseColor.xyz, float3(2.2, 2.2, 2.2)), 1 );
    // --- fragment: toWorldSpaceBatched   (cond 0102c10000000000000000000000000000000000000000ff)
    int meshBatchIndex1 = toInt(Current.indices.x);
    Current.position.xyz *= batchInstanceInfo[meshBatchIndex1].translation.w;
    Current.position.xyz = batchedQuat(batchInstanceInfo[meshBatchIndex1].rotation, Current.position.xyz);
    Current.position.xyz += batchInstanceInfo[meshBatchIndex1].translation.xyz;
    // --- fragment: deformAbandonedVS   (cond 0102cf0000000000000000000000000000001000000010ff)
    {
    for(int i = 0; i < kNumDeforms; ++i)
    {
    float len = dot(Current.position.xyz, kDeformDir[i]);
    float amount = kDeformAmplitude[i] * sin(len / kDeformWavelength[i]);
    Current.position.xyz += amount * kDeformAxis[i];
    }
    }
    // --- fragment: modelPositionBatched   (cond 0102c10000000000000000000000000000004000000040ff)
    int meshBatchIndex3 = toInt(Current.indices.x);
    float3 modelPos = batchInstanceInfo[meshBatchIndex3].translation.xyz;
    // --- fragment: modelPosition   (cond 0000000000000000000000000000000000004000000040ff)
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
    // --- fragment: building4DataViewVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = float4(uv, 0, 0);
    Current.texcoord<t1> = float4(tileSize, tileOffset);
    Current.texcoord<t2> = float4(worldNormal, 0);
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (9 fragments; each may be conditionally enabled)
//==============================================================================
static const bool isAbandoned = true;
static const bool isAbandoned = false;
sampler tintMapSampler;
sampler normalMapSampler;
sampler shaderMapSampler;
sampler tintPaletteSampler;
sampler interiorMapSampler;
uniform sampler2D deferredLightingSampler       : register(s12);
uniform sampler2D deferredNormalSampler         : register(s14);
float4 GetDeferredLight( float2 screenUV )
{
return tex2D( deferredLightingSampler, screenUV );
}
float3 GetDeferredNormal( float2 screenUV )
{
float4 sample = tex2D( deferredNormalSampler, screenUV );
sample.xyz = normalize(sample.xyz * 2.0 - 1.0);
return sample.xyz;
}
float4 GetDeferredNormalAndSpec( float2 screenUV )
{
float4 sample = tex2D( deferredNormalSampler, screenUV );
sample.xyz = normalize(sample.xyz * 2.0 - 1.0);
return sample;
}
uniform float4 screenInfo;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;
uniform float4 worldFarCorners[4];
float CalcPhongSpec( float3 lightDir, float3 reflectedNormal, float specE )
{
float nDotR = saturate(dot(reflectedNormal, lightDir));
specE = max(specE, 0.001f);
float spec1 = pow(nDotR, specE);
return spec1;
}
float CalcBlinnPhongSpec( float3 lightDir, float3 viewDir, float3 normal, float specE )
{
float3 halfVector = normalize(lightDir - viewDir);
float nDotH = saturate(dot(normal, halfVector));
specE = max(specE, 0.001f);
float spec = pow(nDotH, specE);
return spec;
}
float CalcBlinnPhongSchlick(float3 lightDir, float3 viewDir, float3 normal, float specE, float specF)
{
float3 halfVector = normalize(lightDir - viewDir);
float nDotH = saturate(dot(normal, halfVector));
specE = max(specE, 0.001f);
float spec = pow(nDotH, specE);
float specNormalizingFactor = (specE + 2) / 8;
float schlick = specF + (1.0f - specF) * exp2(-8.656170 * saturate(dot(lightDir, halfVector))); // 8.656170 == 1/ln(2) * 6
//float schlick = specF + (1 - specF)*pow((1 - dot(halfVector,lightDir)),5);
return spec*specNormalizingFactor*schlick;
}
extern uniform sampler lightScalarSampler : register(s13);
float3 DataViewLightingModified
(
float2 screenUV,
float3 normal,
float3 viewVector,
float3 diffuseColor,
float3 specColor
)
{
float ambientEnabled = 1.0;
float specE = 10;
float reflectance = 0.1;
float3 ambient = diffuseColor * 0.05f;
normal = normalize(normal);
float n_dot_l = saturate((dot(sunSky.mSunDir.xyz, normal) + 1.0f) * 0.5f);
//float n_dot_l = saturate(dot(sunSky.mSunDir.xyz, normal));
float spec = CalcBlinnPhongSchlick(sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance);
float3 diffuse = (diffuseColor * n_dot_l);
float3 specContrib = specColor * spec;
return diffuse + specContrib + ambient * ambientEnabled;
}
float3 DataViewLightingModifiedDirect
(
float3 normal,
float3 viewVector,
float3 diffuseColor,
float3 specColor
)
{
float ambientEnabled = 1.0;
float specE = 10;
float reflectance = 0.1;
float3 ambient = diffuseColor * 0.05f;
normal = normalize(normal);
float n_dot_l = saturate((dot(sunSky.mSunDir.xyz, normal) + 1.0f) * 0.5f);
//float n_dot_l = saturate(dot(sunSky.mSunDir.xyz, normal));
float spec = CalcBlinnPhongSchlick(sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance);
float3 diffuse = (diffuseColor * n_dot_l);
float3 specContrib = specColor * spec;
return diffuse + specContrib + ambient * ambientEnabled;
}
uniform float4 contourColor;

void main_pixel()
{
    // --- fragment: setAbandoned   (cond 0102cf0000000000000000000000000000002000000020ff)
    // --- fragment: setAbandoned   (cond 0102d00000000000000000000000000000002000000020ff)
    // --- fragment: nonAbandoned   (cond 0000000000000000000000000000000000002000000020ff)
    // --- fragment: building4SamplersPS   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: deferredDiffuseEnabled   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: building4UnpackDataViewPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord<t0>.xy;
    float4 regionXform = In.texcoord<t1>;
    float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
    float3 worldNormal = In.texcoord<t2>.xyz;
    // --- fragment: building4Clip   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv_ddx = ddx(uv * regionXform.xy);
    float2 uv_ddy = ddy(uv * regionXform.xy);
    float2 baseUv = frac(uv) * regionXform.xy + regionXform.zw;
    float4 baseTintValues = tex2Dgrad(tintMapSampler, baseUv, uv_ddx, uv_ddy);
    Current.color.a = (baseTintValues.a - 0.5 < 0)?0:1;
    // --- fragment: building4DataViewPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 instanceColor = In.color.xyz;
    float3 worldViewDirection = normalize(lerp(lerp(worldFarCorners[1],worldFarCorners[0],screenUV.y),lerp(worldFarCorners[3],worldFarCorners[2],screenUV.y),screenUV.x)).xyz;
    float3 normal = worldNormal;
    float4 finalColor = float4(DataViewLightingModified(screenUV, normal, worldViewDirection,
    instanceColor, instanceColor), 1);
    Current.color = finalColor;
    // --- fragment: building4DataViewBlendPS   (cond 0102c70000000000000000000000000000000000000000ff)
    Current.color *= contourColor.a;
    Current.color.a = contourColor.a;
}
