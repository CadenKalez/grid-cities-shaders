// Material shader: sim_impostor
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (6 fragments; each may be conditionally enabled)
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
uniform struct { float4 projScale; float4 projOffset; float4 scale[8]; float4 offset[8]; float4x4 transform[8];} scImpostorAtlasPosition;
uniform float4x3 worldToCamera;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000000000000000000000000000000000ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: copyUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: impostorOffscreenInstanceData   (cond 0000000000000000000000000000000000000000000000ff)
    int angle = int(In.texcoord4.x * 255 + 0.5);
    // --- fragment: skinScaleOff   (cond 0100030000000000000000000000000000000000000000ff)
    // --- fragment: skinPositionNormalTangent   (cond 0100030000000000000000000000000000000000000000ff)
    SkinPosNormalTangent(int(skinWeights.x), Current.indices, Current.weights, Current.position, Current.normal.xyz, Current.tangent.xyz);
    modelPosition = Current.position;
    // --- fragment: simImpostor   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position.xyz = mul(float4(Current.position.xyz,0), scImpostorAtlasPosition.transform[angle]).xyz;
    Current.position.xyz = mul(float4(Current.position.xyz,0), worldToCamera);
    Current.position.xyz *= scImpostorAtlasPosition.projScale.xyz;
    Current.position.xyz += scImpostorAtlasPosition.projOffset.xyz;
    Current.texcoord<t0> = float4(Current.position.xyz, 0);
    Current.position.xyz *= scImpostorAtlasPosition.scale[angle].xyz;
    Current.position.xyz += scImpostorAtlasPosition.offset[angle].xyz;
    float3 vertNormal = Current.normal.xyz;
    vertNormal = mul(float4(vertNormal, 0), scImpostorAtlasPosition.transform[angle]).xyz;
    Current.texcoord<t1> = float4(vertNormal, 1);
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
static const bool kPerPixelDepth = true;
float4 ImpostorUnpackNormalDepth(float4 normalMapSample)
{
float2 normalXY = normalMapSample.xy * 2 - 1;
float  xyLen = dot(normalXY, normalXY);
float  depthZSign = normalMapSample.z - 0.5;
float  pixDepth = abs(depthZSign * 2);
float  zSign = (depthZSign >= 0) ? 1 : -1;
float  normalZ = zSign * sqrt(1 - xyLen);
return float4(normalXY, normalZ, pixDepth);
}
float3 ImpostorPackNormalDepth(float3 normal, float pixelDepth)
{
normal = normalize(normal);
float zSign = (normal.z >= 0) ? 0.5 : -0.5;
return float3(normal.xy * 0.5 + 0.5, zSign*pixelDepth + 0.5);
}

void main_pixel()
{
    // --- fragment: simImpostorDepthFragments   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: simImpostor   (cond 0000000000000000000000000000000000000000000000ff)
    float3 clipPosition = In.texcoord<t1>.xyz;
    float3 vertexNormal = In.texcoord<t2>.xyz;
    clip(float4(1 + clipPosition.xy, 1 - clipPosition.xy));
    float4 texColor = tex2D(Sampler<s0>, In.texcoord<t0>.xy);
    Current.color.rgba = texColor;
    float3 outputNormalMap = ImpostorPackNormalDepth(vertexNormal.xyz, clipPosition.z);
    Current.color1.rgba = float4(outputNormalMap, 1);
}
