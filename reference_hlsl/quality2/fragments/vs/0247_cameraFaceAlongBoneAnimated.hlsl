// Shader fragment  [VS slot 247]  cameraFaceAlongBoneAnimated

// ---- uniform parameters ----
uniform float4 poseMatrices[90];   // reg-meta 02440244005a000000000008
uniform float4 SkinBones[90];   // reg-meta 00040004005a000000000008

// ---- fragment body (spliced into the generated main()) ----
bool useCameraFacing = Current.color.r >= 0.5;
int simsIndex1 = toInt(Current.indices.x);
float3x4 skinMatrix;
if(useCameraFacing)
skinMatrix = float3x4(poseMatrices[simsIndex1-3], poseMatrices[simsIndex1-2], poseMatrices[simsIndex1-1]);
else
skinMatrix = float3x4(SkinBones[simsIndex1+0], SkinBones[simsIndex1+1], SkinBones[simsIndex1+2]);
Current.position.xyz = mul(skinMatrix, Current.position.xyzw);
Current.normal.xyz = mul(make_float3x3(skinMatrix), Current.normal.xyz);
Current.tangent.xyz = mul(make_float3x3(skinMatrix), Current.tangent.xyz);
if(useCameraFacing)
{
// position/normal/tangent are now in bone space
float3x4 poseToBone = skinMatrix;
float3x4 poseToModel = float3x4(SkinBones[simsIndex1+0], SkinBones[simsIndex1+1], SkinBones[simsIndex1+2]);
float3 poseToModelTranslate = float3(poseToModel[0].w, poseToModel[1].w, poseToModel[2].w);
float3 invTranslate = -mul(float3(poseToBone[0].w, poseToBone[1].w, poseToBone[2].w),make_float3x3(poseToBone));
// Figure out the translation from the animation matrix
float3 animToModelTranslate = poseToModelTranslate + mul(make_float3x3(poseToModel), invTranslate);
// Figure out the first row of the bone->model matrix
//    pose->model * (pose->bone)^-1 = bone->model
float3 animX = float3(
dot(poseToModel[0].xyz, poseToBone[0].xyz),
dot(poseToModel[1].xyz, poseToBone[0].xyz),
dot(poseToModel[2].xyz, poseToBone[0].xyz));
// Create a new animation matrix that preserves the bone->model of the x direction
// but changes Y and Z to rotate in camera space
float3 boneX = animX;
float3 boneY = normalize(cross(boneX, localCameraDirection.xyz));
float3 boneZ = cross(boneX, boneY);
float4x3 boneToModelTranspose = float4x3(boneX, boneY, boneZ, animToModelTranslate);
Current.normal.xyz = mul(Current.normal.xyz, make_float3x3(boneToModelTranspose));
Current.tangent.xyz = mul(Current.tangent.xyz, make_float3x3(boneToModelTranspose));
Current.position.xyz = mul(Current.position.xyzw, boneToModelTranspose);
}
