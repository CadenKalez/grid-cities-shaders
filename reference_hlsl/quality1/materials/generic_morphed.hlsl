// Material shader: generic_morphed
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (33 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 materialColor;
static const bool nonUniformScale = (true);
static const bool nonUniformScale = (false);
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
// to match skinning convention
void TransformPosNormalTangent
(
float4 row0, float4 row1, float4 row2, // tfmp
inout float4 position,
inout float3 normal,
inout float3 tangent
)
{
// the compiler strips unused elements
float4 p = position;
position.x = dot(p, row0);
position.y = dot(p, row1);
position.z = dot(p, row2);
float3 n = normal;
normal.x = dot(n, row0.xyz);
normal.y = dot(n, row1.xyz);
normal.z = dot(n, row2.xyz);
float3 t = tangent;
tangent.x = dot(t, row0.xyz);
tangent.y = dot(t, row1.xyz);
tangent.z = dot(t, row2.xyz);
// normalize
normal  = normalize(normal);
tangent = normalize(tangent);
}
void TransformPosNormal(float4 row0, float4 row1, float4 row2, inout float4 position, inout float3 normal)
{
float3 dummy = float3(1, 1, 1);
TransformPosNormalTangent(row0, row1, row2, position, normal, dummy);
}
void TransformPos(float4 row0, float4 row1, float4 row2, inout float4 position)
{
float3 dummy = float3(1, 1, 1);
TransformPosNormalTangent(row0, row1, row2, position, dummy, dummy);
}
// to match skinning convention
void TransformPosNormalTangent
(
float4 row0, float4 row1, float4 row2, // tfmp
inout float4 position,
inout float3 normal,
inout float3 tangent
)
{
// the compiler strips unused elements
float4 p = position;
position.x = dot(p, row0);
position.y = dot(p, row1);
position.z = dot(p, row2);
float3 n = normal;
normal.x = dot(n, row0.xyz);
normal.y = dot(n, row1.xyz);
normal.z = dot(n, row2.xyz);
float3 t = tangent;
tangent.x = dot(t, row0.xyz);
tangent.y = dot(t, row1.xyz);
tangent.z = dot(t, row2.xyz);
// normalize
normal  = normalize(normal);
tangent = normalize(tangent);
}
void TransformPosNormal(float4 row0, float4 row1, float4 row2, inout float4 position, inout float3 normal)
{
float3 dummy = float3(1, 1, 1);
TransformPosNormalTangent(row0, row1, row2, position, normal, dummy);
}
void TransformPos(float4 row0, float4 row1, float4 row2, inout float4 position)
{
float3 dummy = float3(1, 1, 1);
TransformPosNormalTangent(row0, row1, row2, position, dummy, dummy);
}
// to match skinning convention
void TransformPosNormalTangent
(
float4 row0, float4 row1, float4 row2, // tfmp
inout float4 position,
inout float3 normal,
inout float3 tangent
)
{
// the compiler strips unused elements
float4 p = position;
position.x = dot(p, row0);
position.y = dot(p, row1);
position.z = dot(p, row2);
float3 n = normal;
normal.x = dot(n, row0.xyz);
normal.y = dot(n, row1.xyz);
normal.z = dot(n, row2.xyz);
float3 t = tangent;
tangent.x = dot(t, row0.xyz);
tangent.y = dot(t, row1.xyz);
tangent.z = dot(t, row2.xyz);
// normalize
normal  = normalize(normal);
tangent = normalize(tangent);
}
void TransformPosNormal(float4 row0, float4 row1, float4 row2, inout float4 position, inout float3 normal)
{
float3 dummy = float3(1, 1, 1);
TransformPosNormalTangent(row0, row1, row2, position, normal, dummy);
}
void TransformPos(float4 row0, float4 row1, float4 row2, inout float4 position)
{
float3 dummy = float3(1, 1, 1);
TransformPosNormalTangent(row0, row1, row2, position, dummy, dummy);
}
uniform float4 batchColors[48];
uniform struct {float4 color;float4 data;} singleModelBatchData;
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
float3 batchedQuat(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
float3 quatrot(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
uniform float4x3 modelToWorld;
uniform float4x3 modelToWorld;
uniform float4 shCoeffs[9];
uniform float4 worldCameraDirection;
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
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: copyVertexColor   (cond 0000000000000000000008000000000000000200000002ff)
    // --- fragment: whiteVertexColor   (cond 0000000000000000000000000000000000000200000002ff)
    Current.color = float4(1, 1, 1, 1);
    // --- fragment: applyMaterialColor   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= materialColor;
    // --- fragment: copyUV0   (cond 0a00000000000000000040000000000000000000000004ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment:    (cond 0c00010001000000000000000000000000000000000008ff)
    // --- fragment: skinScaleOn   (cond 0500030207000000004004000000000000001000000010ff)
    // --- fragment: skinScaleOff   (cond 0100030000000000000000000000000000001000000010ff)
    // --- fragment: skinPositionNormalTangent   (cond 010003000000000008c044000000000000002000000020ff)
    SkinPosNormalTangent(int(skinWeights.x), Current.indices, Current.weights, Current.position, Current.normal.xyz, Current.tangent.xyz);
    modelPosition = Current.position;
    // --- fragment: skinPositionNormal   (cond 010003000000000000c004000000000000002000000020ff)
    SkinPosNormal(int(skinWeights.x), Current.indices, Current.weights, Current.position, Current.normal.xyz);
    modelPosition = Current.position;
    // --- fragment: skinPosition   (cond 010003000000000000c000000000000000002000000020ff)
    SkinPos(int(skinWeights.x), Current.indices, Current.weights, Current.position);
    modelPosition = Current.position;
    // --- fragment: skinPositionNormalTangent1   (cond 0100030000000000084044000000000000002000000020ff)
    SkinPosNormalTangent(1, Current.indices, float4(1,0,0,0), Current.position, Current.normal.xyz, Current.tangent.xyz);
    modelPosition = Current.position;
    // --- fragment: skinPositionNormal1   (cond 0100030000000000004004000000000000002000000020ff)
    SkinPosNormal(1, Current.indices, float4(1,0,0,0), Current.position, Current.normal.xyz);
    modelPosition = Current.position;
    // --- fragment: skinPosition1   (cond 0100030000000000004000000000000000002000000020ff)
    SkinPos(1, Current.indices, float4(1,0,0,0), Current.position);
    modelPosition = Current.position;
    // --- fragment: instancingPositionNormalTangent   (cond 0000000000000000080444000000000000004000000040ff)
    TransformPosNormalTangent(In.texcoord1, In.texcoord2, In.texcoord3, Current.position, Current.normal.xyz, Current.tangent.xyz);
    modelPosition = Current.position;
    float3 worldNormal  = Current.normal.xyz;
    float3 worldTangent = Current.tangent.xyz;
    // --- fragment: instancingPositionNormal   (cond 0000000000000000000404000000000000004000000040ff)
    TransformPosNormal(In.texcoord1, In.texcoord2, In.texcoord3, Current.position, Current.normal.xyz);
    modelPosition = Current.position;
    float3 worldNormal = Current.normal.xyz;
    // --- fragment: instancingPosition   (cond 0000000000000000000400000000000000004000000040ff)
    TransformPos(In.texcoord1, In.texcoord2, In.texcoord3, Current.position);
    modelPosition = Current.position;
    // --- fragment: batchInstanceColorVS   (cond 0102c10000000000000000000000000000008000000080ff)
    int meshBatchIndex4 = toInt(Current.indices.x);
    float4 rawInstanceInfo = batchColors[meshBatchIndex4];
    float4 instanceColor = rawInstanceInfo;
    float4 instanceData = float4(1, 1, 1, rawInstanceInfo.w);
    // --- fragment: noInstanceDataVS   (cond 0000000000000000000000000000000000008000000080ff)
    float4 rawInstanceInfo = singleModelBatchData.data;
    float4 instanceColor = singleModelBatchData.color;
    float4 instanceData = singleModelBatchData.data;
    // --- fragment: toWorldSpaceBatched   (cond 0102c10000000000000000000000000000000000000000ff)
    int meshBatchIndex1 = toInt(Current.indices.x);
    Current.position.xyz *= batchInstanceInfo[meshBatchIndex1].translation.w;
    Current.position.xyz = batchedQuat(batchInstanceInfo[meshBatchIndex1].rotation, Current.position.xyz);
    Current.position.xyz += batchInstanceInfo[meshBatchIndex1].translation.xyz;
    // --- fragment: worldSpaceBatchedNormalTangent   (cond 0102c10000000000000000000000000000014000000100ff)
    int meshBatchIndex2 = toInt(Current.indices.x);
    float3 worldNormal = normalize(quatrot(batchInstanceInfo[meshBatchIndex2].rotation, Current.normal.xyz));
    float3 worldTangent = normalize(quatrot(batchInstanceInfo[meshBatchIndex2].rotation, Current.tangent.xyz));
    float3 worldBinormal = cross( worldTangent, worldNormal );
    // --- fragment: worldSpaceNormalTangent   (cond 0000000000000000080044000000000000014000000100ff)
    float3 worldNormal  = mul(Current.normal.xyz,  make_float3x3(modelToWorld));
    float3 worldTangent = mul(Current.tangent.xyz, make_float3x3(modelToWorld));
    worldNormal  = normalize(worldNormal);
    worldTangent = normalize(worldTangent);
    float3 worldBinormal = cross(worldTangent, worldNormal);
    // --- fragment: worldSpaceNormal   (cond 0000000000000000000004000000000000014000000100ff)
    float3 worldNormal  = mul(Current.normal.xyz, make_float3x3(modelToWorld));
    worldNormal  = normalize(worldNormal);
    // --- fragment: setupSHTangent   (cond 0000000000000000080044000000000000000000000000ff)
    Current.texcoord<t0>.xyz = worldTangent;
    // --- fragment: scLightingApply   (cond 01028b0000000000000004000000000000100000001000ff)
    Current.texcoord<t0> = worldNormal;
    // --- fragment: shLightingDiffSpec9   (cond 0000000000000000000004000000000000100000001000ff)
    Current.texcoord<t0> = worldNormal;
    SHDiffSpec9(worldNormal, Current.texcoord<t1>, Current.texcoord<t2>);
    // --- fragment: scLightingApply   (cond 0000000000000000000004000000000000100000001000ff)
    Current.texcoord<t0> = worldNormal;
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: instancingColor   (cond 0000000000000000000000000000400000000000000000ff)
    Current.color *= In.texcoord4;
    // --- fragment: applyBatchColor   (cond 0102c10000000000000000000000000000000000000000ff)
    Current.color.rgb = instanceColor.rgb;
    // --- fragment: shLightingDiffSpec9   (cond 0000000000000000000004000000000000100000001000ff)
    Current.texcoord<t0> = worldNormal;
    SHDiffSpec9(worldNormal, Current.texcoord<t1>, Current.texcoord<t2>);
    // --- fragment: shLightingDiffSpec9   (cond 0000000000000000000004000000000000100000001000ff)
    Current.texcoord<t0> = worldNormal;
    SHDiffSpec9(worldNormal, Current.texcoord<t1>, Current.texcoord<t2>);
}

//==============================================================================
// PIXEL SHADER  (16 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuseTextureSampler;
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
uniform float4 materialParams;
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
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;
uniform float4 worldCameraDirection;
static const bool  kAvoidDesaturation   = true;
static const bool  kUseSkyTable         = true;
static const float3 kXYZToR = float3( 2.80298,   -1.18735,  -0.437286);
static const float3 kXYZToG = float3(-1.07909,    1.97927,   0.0423073);
static const float3 kXYZToB = float3( 0.0746015, -0.248513,  1.08196);
float3 xyYToXYZ(float3 c)
{
return float3(c.x, c.y, 1.0 - c.x - c.y) * c.z / c.y;
}
float Perez
(
float4 lambdas,
float  cosTheta,
float  gammaS,
float  cosGamma
)
{
return (1.0 + lambdas.x * exp(lambdas.y / cosTheta))
* (1.0 + lambdas.z * exp(gammaS) + lambdas.w * cosGamma * cosGamma);
}
float3 SkyColorTG(cSunSkyInfo info, float cosTheta, float cosGamma, float gamma)
{
float3 xyY;
float3 a = info.mPerezA.xyz;
float3 b = info.mPerezB.xyz;
float3 c = info.mPerezC.xyz;
float3 d = info.mPerezD.xyz;
float3 e = info.mPerezE.xyz;
float3 ecb = exp(b / cosTheta);
float3 egd = exp(gamma * d);
float cg2 = cosGamma * cosGamma;
xyY = (1 + a * ecb) * (1 + c * egd + e * cg2);
float3 skyBase = info.mInvDensity.xyz;
xyY *= skyBase;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y;
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressedWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTable(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressed(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
sampler skyTermTableXXX : register(s11);
float3 SkyColor(cSunSkyInfo info, float3 v)
{
if (kUseSkyTable)
return SkyColorTableCompressedWithTuning(skyTermTableXXX, info, saturate(v.z), dot(info.mSunDir.xyz, v), 0);
else
{
float cosTheta = saturate(v.z + 1e-6);
float cosGamma = dot(info.mSunDir.xyz, v);
float gamma = acos(cosGamma);
return SkyColorTG(info, cosTheta, cosGamma, gamma);
}
}
float3 SkyColorConv(cSunSkyInfo info, float3 v, float s)
{
float cosTheta = v.z;
float cosGamma = dot(info.mSunDir.xyz, v);
return SkyColorTableCompressed(skyTermTableXXX, info, cosTheta, cosGamma, s);
}
void EnvLighting(float3 normal, float3 viewVector, float s, out float3 shColorDiff, out float3 shColorSpec)
{
s *= 0.75;
float3 reflDir = reflect(viewVector, normal);
float3 sampleDir = normal * (1 - s) + reflDir * s;
shColorDiff = SkyColorConv(sunSky, sampleDir, 1 - s);
shColorSpec = shColorDiff;
shColorDiff *= 1-s;
shColorSpec *= s;
}
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
void SceneLighting
(
half3 normal,
half3 viewVector,
half  glossyStrength,
half  reflectance,
half  specE,
half  specStrength,
inout half3 shColorDiff,
inout half3 shColorSpec,
inout half3 specHighlight
)
{
EnvLighting(normal, viewVector, glossyStrength, shColorDiff, shColorSpec);
half sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
half spec = CalcBlinnPhongSchlick( sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance );
specHighlight = spec * specStrength * sunMod * sunSky.mSunColor.rgb;
sunMod = pow(sunMod,(1+glossyStrength));
shColorDiff += sunMod * sunSky.mSunColor.rgb;
}
void SceneLighting
(
half2 screenUV,
half3 normal,
half3 viewVector,
half  glossyStrength,
half  reflectance,
half  specE,
half  specStrength,
inout half3 shColorDiff,
inout half3 shColorSpec,
inout half3 specHighlight
)
{
SceneLighting(
normal, viewVector, glossyStrength, reflectance, specE, specStrength,
shColorDiff, shColorSpec, specHighlight );
}
uniform float4 shCoeffs[16];
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[1];
uniform float4 worldCameraDirection;
uniform float4 screenInfo;
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
void SHLighting
(
float3 normal,
float3 viewVector,
inout float3 shColorDiff,
inout float3 shColorSpec,
bool   translucency
)
{
float3 x0;
float3 reflectedNormal = reflect(viewVector, normal);
if (translucency)
{
x0 = -normal;
}
else
{
x0 = reflectedNormal;
}
float3 x1 = x0 * x0;
float3 x2 = x0 * x0.yzx;
if (!kSaveInstructions)
{
shColorSpec += shCoeffs[ 9].xyz * (3 * x1.x - x1.y) * x0.y;
shColorSpec += shCoeffs[10].xyz * x1.x * x0.z;
}
shColorSpec += shCoeffs[11].xyz * (5 * x1.z - 1) * x0.y;
shColorSpec += shCoeffs[12].xyz * (5 * x1.z - 3) * x0.z;
shColorSpec += shCoeffs[13].xyz * (5 * x1.z - 1) * x0.x;
if (!kSaveInstructions)
{
shColorSpec += shCoeffs[14].xyz * (x1.x - x1.y) * x0.z;
shColorSpec += shCoeffs[15].xyz * (x1.x - 3 * x1.y) * x0.x;
}
}
float3 SHLightingGlossy16
(
float3 colorIn,
float3 normal,
float3 shColorDiff,
float3 shColorSpec,
float  glossyStrength,
float  specE,
float  specStrength,
bool   translucency
)
{
if (kSaveInstructions)
{
// specE = 4; // saves 1
// glossyStrength = 0.5; // saves 3
}
SHLighting(normal, worldCameraDirection.xyz, shColorDiff, shColorSpec, translucency);
if (translucency)
{
shColorSpec *= glossyStrength;
}
else
{
float s = glossyStrength;
shColorDiff *= 1 - s;
shColorSpec *= s;
}
colorIn *= (shColorSpec + shColorDiff);
// if (useSpecHighlight)
{
float spec = CalcBlinnPhongSpec( dirLightsWorld[0].mDir.xyz, worldCameraDirection.xyz, normal, specE );
colorIn += spec * specStrength * dirLightsWorld[0].mColor.rgb;
}
return colorIn;
}
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;
uniform float4 screenInfo;
uniform float4 worldFarCorners[4];
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}
static const bool  kAvoidDesaturation   = true;
static const bool  kUseSkyTable         = true;
static const float3 kXYZToR = float3( 2.80298,   -1.18735,  -0.437286);
static const float3 kXYZToG = float3(-1.07909,    1.97927,   0.0423073);
static const float3 kXYZToB = float3( 0.0746015, -0.248513,  1.08196);
float3 xyYToXYZ(float3 c)
{
return float3(c.x, c.y, 1.0 - c.x - c.y) * c.z / c.y;
}
float Perez
(
float4 lambdas,
float  cosTheta,
float  gammaS,
float  cosGamma
)
{
return (1.0 + lambdas.x * exp(lambdas.y / cosTheta))
* (1.0 + lambdas.z * exp(gammaS) + lambdas.w * cosGamma * cosGamma);
}
float3 SkyColorTG(cSunSkyInfo info, float cosTheta, float cosGamma, float gamma)
{
float3 xyY;
float3 a = info.mPerezA.xyz;
float3 b = info.mPerezB.xyz;
float3 c = info.mPerezC.xyz;
float3 d = info.mPerezD.xyz;
float3 e = info.mPerezE.xyz;
float3 ecb = exp(b / cosTheta);
float3 egd = exp(gamma * d);
float cg2 = cosGamma * cosGamma;
xyY = (1 + a * ecb) * (1 + c * egd + e * cg2);
float3 skyBase = info.mInvDensity.xyz;
xyY *= skyBase;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y;
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressedWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTable(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressed(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
sampler skyTermTableXXX : register(s11);
float3 SkyColor(cSunSkyInfo info, float3 v)
{
if (kUseSkyTable)
return SkyColorTableCompressedWithTuning(skyTermTableXXX, info, saturate(v.z), dot(info.mSunDir.xyz, v), 0);
else
{
float cosTheta = saturate(v.z + 1e-6);
float cosGamma = dot(info.mSunDir.xyz, v);
float gamma = acos(cosGamma);
return SkyColorTG(info, cosTheta, cosGamma, gamma);
}
}
float3 SkyColorConv(cSunSkyInfo info, float3 v, float s)
{
float cosTheta = v.z;
float cosGamma = dot(info.mSunDir.xyz, v);
return SkyColorTableCompressed(skyTermTableXXX, info, cosTheta, cosGamma, s);
}
void EnvLighting(float3 normal, float3 viewVector, float s, out float3 shColorDiff, out float3 shColorSpec)
{
s *= 0.75;
float3 reflDir = reflect(viewVector, normal);
float3 sampleDir = normal * (1 - s) + reflDir * s;
shColorDiff = SkyColorConv(sunSky, sampleDir, 1 - s);
shColorSpec = shColorDiff;
shColorDiff *= 1-s;
shColorSpec *= s;
}
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
void SceneLighting
(
float2 screenUV,
float3 normal,
float3 viewVector,
float  glossyStrength,
float  reflectance,
float  specE,
float  specStrength,
inout float3 shColorDiff,
inout float3 shColorSpec,
inout float3 specHighlight,
out   float  shadow
)
{
float4 lightScalar = tex2D(lightScalarSampler,screenUV);
float directShadow  = lightScalar.x;
float ambientShadow = lightScalar.y;
shadow = directShadow;
EnvLighting(normal, viewVector, glossyStrength, shColorDiff, shColorSpec);
shColorDiff *= ambientShadow;
shColorSpec *= ambientShadow;
float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
float spec = CalcBlinnPhongSchlick( sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance );
specHighlight = spec * specStrength * sunMod * sunSky.mSunColor.rgb * directShadow;
sunMod = pow(max(sunMod,0.0001),1.0+glossyStrength);
//sunMod = exp(sunMod*log(1+glossyStrength));
shColorDiff += sunMod * sunSky.mSunColor.rgb * directShadow;
float4 deferredLight = GetDeferredLight( screenUV );
shColorDiff += deferredLight.rgb;
shColorSpec += deferredLight.a;
}
void SceneLighting
(
float2 screenUV,
float3 normal,
float3 viewVector,
float  glossyStrength,
float  reflectance,
float  specE,
float  specStrength,
inout float3 shColorDiff,
inout float3 shColorSpec,
inout float3 specHighlight
)
{
float shadow = 1.0f;
SceneLighting(
screenUV, normal, viewVector,
glossyStrength, reflectance, specE, specStrength,
shColorDiff, shColorSpec, specHighlight, shadow );
}
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct {float4 thetaMin;float4 thetaMax;float4 gammaMin;float4 gammaMax;} sunSkyRadianceScales;
uniform float4 screenInfo;
uniform float4 worldFarCorners[4];
static const bool  kAvoidDesaturation   = true;
static const bool  kUseSkyTable         = true;
static const float3 kXYZToR = float3( 2.80298,   -1.18735,  -0.437286);
static const float3 kXYZToG = float3(-1.07909,    1.97927,   0.0423073);
static const float3 kXYZToB = float3( 0.0746015, -0.248513,  1.08196);
float3 xyYToXYZ(float3 c)
{
return float3(c.x, c.y, 1.0 - c.x - c.y) * c.z / c.y;
}
float Perez
(
float4 lambdas,
float  cosTheta,
float  gammaS,
float  cosGamma
)
{
return (1.0 + lambdas.x * exp(lambdas.y / cosTheta))
* (1.0 + lambdas.z * exp(gammaS) + lambdas.w * cosGamma * cosGamma);
}
float3 SkyColorTG(cSunSkyInfo info, float cosTheta, float cosGamma, float gamma)
{
float3 xyY;
float3 a = info.mPerezA.xyz;
float3 b = info.mPerezB.xyz;
float3 c = info.mPerezC.xyz;
float3 d = info.mPerezD.xyz;
float3 e = info.mPerezE.xyz;
float3 ecb = exp(b / cosTheta);
float3 egd = exp(gamma * d);
float cg2 = cosGamma * cosGamma;
xyY = (1 + a * ecb) * (1 + c * egd + e * cg2);
float3 skyBase = info.mInvDensity.xyz;
xyY *= skyBase;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y;
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressedWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableWithTuning(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
const float2 kWhitePointXY = float2(0.33333, 0.33333);
xyY.xy = saturate(kWhitePointXY + (xyY.xy - kWhitePointXY) * info.mSkyColorTuning.y);
xyY.z *= info.mSkyColorTuning.x;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTable(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = tex2D(table, float2(c, s)).xyz;
float3 gammaTerm = tex2D(table, float2(g, 0.5 + s)).xyz;
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
float3 SkyColorTableCompressed(sampler table, cSunSkyInfo info, float cosTheta, float cosGamma, float s)
{
s = (0.5 + 3 * s) / 8;
float c = 0.5f * (cosTheta + 1);
float g = 0.5f * (1.0f - cosGamma);
g = sqrt(g);
float3 thetaTerm = lerp(sunSkyRadianceScales.thetaMin.xyz, sunSkyRadianceScales.thetaMax.xyz, tex2D(table, float2(c, s)).xyz);
float3 gammaTerm = lerp(sunSkyRadianceScales.gammaMin.xyz, sunSkyRadianceScales.gammaMax.xyz, tex2D(table, float2(g, 0.5 + s)).xyz);
float3 xyY = (1 + thetaTerm) * (1 + gammaTerm);
xyY *= info.mInvDensity.xyz;
if (kAvoidDesaturation)
xyY.z = saturate(xyY.z);
float3 cieXYZ = xyYToXYZ(xyY);
float3 skyColor = float3
(
dot(kXYZToR, cieXYZ),
dot(kXYZToG, cieXYZ),
dot(kXYZToB, cieXYZ)
);
return skyColor;
}
sampler skyTermTableXXX : register(s11);
float3 SkyColor(cSunSkyInfo info, float3 v)
{
if (kUseSkyTable)
return SkyColorTableCompressedWithTuning(skyTermTableXXX, info, saturate(v.z), dot(info.mSunDir.xyz, v), 0);
else
{
float cosTheta = saturate(v.z + 1e-6);
float cosGamma = dot(info.mSunDir.xyz, v);
float gamma = acos(cosGamma);
return SkyColorTG(info, cosTheta, cosGamma, gamma);
}
}
float3 SkyColorConv(cSunSkyInfo info, float3 v, float s)
{
float cosTheta = v.z;
float cosGamma = dot(info.mSunDir.xyz, v);
return SkyColorTableCompressed(skyTermTableXXX, info, cosTheta, cosGamma, s);
}
void EnvLighting(float3 normal, float3 viewVector, float s, out float3 shColorDiff, out float3 shColorSpec)
{
s *= 0.75;
float3 reflDir = reflect(viewVector, normal);
float3 sampleDir = normal * (1 - s) + reflDir * s;
shColorDiff = SkyColorConv(sunSky, sampleDir, 1 - s);
shColorSpec = shColorDiff;
shColorDiff *= 1-s;
shColorSpec *= s;
}
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
void SceneLighting
(
float2 screenUV,
float3 normal,
float3 viewVector,
float  glossyStrength,
float  reflectance,
float  specE,
float  specStrength,
inout float3 shColorDiff,
inout float3 shColorSpec,
inout float3 specHighlight,
out   float  shadow
)
{
float4 lightScalar = tex2D(lightScalarSampler,screenUV);
float directShadow  = lightScalar.x;
float ambientShadow = lightScalar.y;
shadow = directShadow;
EnvLighting(normal, viewVector, glossyStrength, shColorDiff, shColorSpec);
shColorDiff *= ambientShadow;
shColorSpec *= ambientShadow;
float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
float spec = CalcBlinnPhongSchlick( sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance );
specHighlight = spec * specStrength * sunMod * sunSky.mSunColor.rgb * directShadow;
sunMod = pow(max(sunMod,0.0001),1.0+glossyStrength);
//sunMod = exp(sunMod*log(1+glossyStrength));
shColorDiff += sunMod * sunSky.mSunColor.rgb * directShadow;
float4 deferredLight = GetDeferredLight( screenUV );
shColorDiff += deferredLight.rgb;
shColorSpec += deferredLight.a;
}
void SceneLighting
(
float2 screenUV,
float3 normal,
float3 viewVector,
float  glossyStrength,
float  reflectance,
float  specE,
float  specStrength,
inout float3 shColorDiff,
inout float3 shColorSpec,
inout float3 specHighlight
)
{
float shadow = 1.0f;
SceneLighting(
screenUV, normal, viewVector,
glossyStrength, reflectance, specE, specStrength,
shColorDiff, shColorSpec, specHighlight, shadow );
}
uniform float4 tintParams;

void main_pixel()
{
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: applyDiffuseTexture   (cond 0a00000000000000000040000000000000000000000004ff)
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
    Current.color *= diffuseTexture;
    // --- fragment: deferredDiffuseDisabled   (cond 0000000000000000000000000000000000020000000200ff)
    // --- fragment: setupSHTangent   (cond 0000000000000000080044000000000000000000000000ff)
    float3 vertDS = In.texcoord<t0>.xyz;
    // --- fragment: setupSHMaterialParams   (cond 0102100000000000000000000000000000040000000c00ff)
    float specE        = materialParams.x;
    float specStrength = materialParams.y;
    float bumpFactor   = materialParams.z;
    float gloss        = materialParams.w;
    // --- fragment: setupSHBasic   (cond 0000000000000000000000000000000000040000000400ff)
    float specStrength = 0;
    float specE = 1;
    float bumpFactor = 1;
    float gloss = kDefaultGloss;
    // --- fragment: setupNMap   (cond 000000000000000008004400000000000000000000000000)
    float4 specNMap = tex2D(Sampler<s0>, In.texcoord0.xy);
    float3 nmapNormal = specNMap.rgb * 2 - 0.9985;
    nmapNormal.z *= bumpFactor;
    specStrength *= specNMap.a ;
    gloss        *= specNMap.a;
    // --- fragment: scLightingDirectApply   (cond 01028b0000000000000004000000000000100000001000ff)
    float3 vertNormal  = In.texcoord<t0>.xyz;
    float3 shColorDiff = float3(0, 0, 0);
    float3 shColorSpec = float3(0, 0, 0);
    vertNormal = normalize(vertNormal);
    float3 bumpNormal = vertNormal;    
    float3 spec = float3(0, 0, 0);
    // Using world camera direction even though it's slightly wrong since we're guaranteed to have world position calculated
    SceneLighting(bumpNormal, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
    Current.color.rgb *= shColorDiff + shColorSpec + spec;
    // --- fragment: shLightingApply   (cond 0000000000000000000004000000000000100000001000ff)
    float3 vertNormal  = In.texcoord<t0>.xyz;
    float3 shColorDiff = In.texcoord<t1>.rgb;
    float3 shColorSpec = In.texcoord<t2>.rgb;
    vertNormal = normalize(vertNormal);
    float3 bumpNormal = vertNormal;    
    Current.color.rgb = SHLightingGlossy16(Current.color.rgb, vertNormal, shColorDiff, shColorSpec, gloss, specE, specStrength, false);
    // --- fragment: scLightingApplyNMap   (cond 000000000000000008004400000000000010000000100000)
    float3 vertNormal    = In.texcoord<t0>.xyz;
    float3 shColorDiff   = float3(0, 0, 0);
    float3 shColorSpec   = float3(0, 0, 0);
    float3 bumpNormal = ApplyNormalMap(vertNormal, vertDS, nmapNormal);
    float2 shScreenUV = (In.vpos.xy + float2(0.5, 0.5)) * screenInfo.zw;
    float3 worldViewDirection = normalize(lerp(lerp(worldFarCorners[1],worldFarCorners[0],shScreenUV.y),lerp(worldFarCorners[3],worldFarCorners[2],shScreenUV.y),shScreenUV.x)).xyz;
    float3 spec = float3(0, 0, 0);
    SceneLighting(shScreenUV, bumpNormal, worldViewDirection, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
    Current.color.rgb *= shColorDiff + shColorSpec + spec;
    // --- fragment: scLightingApply   (cond 0000000000000000000004000000000000100000001000ff)
    float3 vertNormal  = In.texcoord<t0>.xyz;
    float3 shColorDiff = float3(0, 0, 0);
    float3 shColorSpec = float3(0, 0, 0);
    vertNormal = normalize(vertNormal);
    float3 bumpNormal = vertNormal;    
    float2 shScreenUV = (In.vpos.xy + float2(0.5, 0.5)) * screenInfo.zw;
    float3 worldViewDirection = normalize(lerp(lerp(worldFarCorners[1],worldFarCorners[0],shScreenUV.y),lerp(worldFarCorners[3],worldFarCorners[2],shScreenUV.y),shScreenUV.x)).xyz;
    float3 spec = float3(0, 0, 0);
    SceneLighting(shScreenUV, bumpNormal, worldViewDirection, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
    Current.color.rgb *= shColorDiff + shColorSpec + spec;
    // --- fragment: tint   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= tintParams;
    // --- fragment: scLightingDirectApply   (cond 01028b0000000000000004000000000000100000001000ff)
    float3 vertNormal  = In.texcoord<t0>.xyz;
    float3 shColorDiff = float3(0, 0, 0);
    float3 shColorSpec = float3(0, 0, 0);
    vertNormal = normalize(vertNormal);
    float3 bumpNormal = vertNormal;    
    float3 spec = float3(0, 0, 0);
    // Using world camera direction even though it's slightly wrong since we're guaranteed to have world position calculated
    SceneLighting(bumpNormal, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
    Current.color.rgb *= shColorDiff + shColorSpec + spec;
    // --- fragment: shLightingApply   (cond 0000000000000000000004000000000000100000001000ff)
    float3 vertNormal  = In.texcoord<t0>.xyz;
    float3 shColorDiff = In.texcoord<t1>.rgb;
    float3 shColorSpec = In.texcoord<t2>.rgb;
    vertNormal = normalize(vertNormal);
    float3 bumpNormal = vertNormal;    
    Current.color.rgb = SHLightingGlossy16(Current.color.rgb, vertNormal, shColorDiff, shColorSpec, gloss, specE, specStrength, false);
    // --- fragment: scLightingDirectApply   (cond 01028b0000000000000004000000000000100000001000ff)
    float3 vertNormal  = In.texcoord<t0>.xyz;
    float3 shColorDiff = float3(0, 0, 0);
    float3 shColorSpec = float3(0, 0, 0);
    vertNormal = normalize(vertNormal);
    float3 bumpNormal = vertNormal;    
    float3 spec = float3(0, 0, 0);
    // Using world camera direction even though it's slightly wrong since we're guaranteed to have world position calculated
    SceneLighting(bumpNormal, worldCameraDirection.xyz, gloss, gloss, specE, specStrength, shColorDiff, shColorSpec, spec);
    Current.color.rgb *= shColorDiff + shColorSpec + spec;
    // --- fragment: shLightingApply   (cond 0000000000000000000004000000000000100000001000ff)
    float3 vertNormal  = In.texcoord<t0>.xyz;
    float3 shColorDiff = In.texcoord<t1>.rgb;
    float3 shColorSpec = In.texcoord<t2>.rgb;
    vertNormal = normalize(vertNormal);
    float3 bumpNormal = vertNormal;    
    Current.color.rgb = SHLightingGlossy16(Current.color.rgb, vertNormal, shColorDiff, shColorSpec, gloss, specE, specStrength, false);
}
