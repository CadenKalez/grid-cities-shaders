// Shader fragment  [VS slot 231]  cameraFaceAlongBone

// ---- uniform parameters ----
uniform float4 poseMatrices[(180)];   // reg-meta 0244024400b4000000000008

// ---- fragment body (spliced into the generated main()) ----
const int kNumNormalBones = 1;
int index = toInt(Current.indices.x);
// index 0 is ignored so we don't even upload that pose mat
float3x4 poseToBone = float3x4(poseMatrices[index-3], poseMatrices[index-2], poseMatrices[index-1]);
float4 bonePos = Current.position;
float4 boneNormal = Current.normal;
float4 boneTangent = Current.tangent;
bonePos.xyz = mul(poseToBone,Current.position.xyzw);
boneNormal.xyz = mul(make_float3x3(poseToBone),Current.normal.xyz);
boneTangent.xyz = mul(make_float3x3(poseToBone),Current.tangent.xyz);
// Invert the pose->bone matrix to get a skinning matrix bone->model, but changing the rotation to
// keep camera facing.
//
// We don't support scale in the bind pose matrices.
float3  invTranslate = -mul(float3(poseToBone[0].w, poseToBone[1].w, poseToBone[2].w),make_float3x3(poseToBone));
float3 boneX = poseToBone[0].xyz;
float3 boneY = normalize(cross(boneX, localCameraDirection.xyz));
float3 boneZ = cross(boneX, boneY);
float4x3 boneToModelTranspose = float4x3(boneX, boneY, boneZ, invTranslate);
if(index >= kNumNormalBones*3)
{
Current.normal.xyz = mul(boneNormal.xyz, make_float3x3(boneToModelTranspose));
Current.tangent.xyz = mul(boneTangent.xyz, make_float3x3(boneToModelTranspose));
Current.position.xyz = mul(bonePos, boneToModelTranspose);
}
