// Material shader: generic_skinning_nolightnofog
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (14 fragments; each may be conditionally enabled)
//==============================================================================
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
uniform float4 materialColor;
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
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];
float3 batchedQuat(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: skinScaleOff   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: skinPosition   (cond 010003000000000000c000000000000000000100000001ff)
    SkinPos(int(skinWeights.x), Current.indices, Current.weights, Current.position);
    modelPosition = Current.position;
    // --- fragment: skinPosition1   (cond 0100030000000000004000000000000000000100000001ff)
    SkinPos(1, Current.indices, float4(1,0,0,0), Current.position);
    modelPosition = Current.position;
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000200000002ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000200000002ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: copyVertexColor   (cond 0000000000000000000008000000000000000400000004ff)
    // --- fragment: whiteVertexColor   (cond 0000000000000000000000000000000000000400000004ff)
    Current.color = float4(1, 1, 1, 1);
    // --- fragment: applyMaterialColor   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= materialColor;
    // --- fragment: copyUV0   (cond 0a00000000000000000040000000000000000000000008ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: instancingPositionNormalTangent   (cond 0000000000000000080444000000000000001000000010ff)
    TransformPosNormalTangent(In.texcoord1, In.texcoord2, In.texcoord3, Current.position, Current.normal.xyz, Current.tangent.xyz);
    modelPosition = Current.position;
    float3 worldNormal  = Current.normal.xyz;
    float3 worldTangent = Current.tangent.xyz;
    // --- fragment: instancingPositionNormal   (cond 0000000000000000000404000000000000001000000010ff)
    TransformPosNormal(In.texcoord1, In.texcoord2, In.texcoord3, Current.position, Current.normal.xyz);
    modelPosition = Current.position;
    float3 worldNormal = Current.normal.xyz;
    // --- fragment: instancingPosition   (cond 0000000000000000000400000000000000001000000010ff)
    TransformPos(In.texcoord1, In.texcoord2, In.texcoord3, Current.position);
    modelPosition = Current.position;
    // --- fragment: toWorldSpaceBatched   (cond 0102c10000000000000000000000000000000000000000ff)
    int meshBatchIndex1 = toInt(Current.indices.x);
    Current.position.xyz *= batchInstanceInfo[meshBatchIndex1].translation.w;
    Current.position.xyz = batchedQuat(batchInstanceInfo[meshBatchIndex1].rotation, Current.position.xyz);
    Current.position.xyz += batchInstanceInfo[meshBatchIndex1].translation.xyz;
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuseTextureSampler;
uniform float4 tintParams;

void main_pixel()
{
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: applyDiffuseTexture   (cond 0a00000000000000000040000000000000000000000008ff)
    float4 diffuseTexture = tex2D(diffuseTextureSampler, In.texcoord<t0>.xy);
    Current.color *= diffuseTexture;
    // --- fragment: tint   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color *= tintParams;
}
