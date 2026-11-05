// Shader fragment  [VS slot 181]  morphRotationAnimVS

// ---- uniform parameters ----
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];   // reg-meta 02bf02bf0090000000000008

// ---- declarations / helper functions ----
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

// ---- fragment body (spliced into the generated main()) ----
int buildingsIndex1 = toInt(Current.indices.x);
float4 animTimes = batchInstanceInfo[buildingsIndex1].animdata;
animMorphRot(In.binormal, In.weights, Current.position.xyz, Current.normal.xyz, Current.tangent.xyz, animTimes);
