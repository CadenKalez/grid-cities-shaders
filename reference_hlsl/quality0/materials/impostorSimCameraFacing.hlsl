// Material shader: impostorSimCameraFacing
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (7 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 worldCameraDirection;
uniform struct { float4 projScale; float4 projOffset; float4 scale[8]; float4 offset[8]; float4x4 transform[8];} scImpostorAtlasPosition;
uniform float4 poseMatrices[90];
uniform float4 SkinBones[90];
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
    // --- fragment: simImpostorCameraDirection   (cond 0000000000000000000000000000000000000000000000ff)
    // rotate world camera back into model direction
    float4 localCameraDirection = worldCameraDirection;
    localCameraDirection.xyz = mul(make_float3x3(scImpostorAtlasPosition.transform[angle]), localCameraDirection.xyz);
    // --- fragment: cameraFaceAlongBoneAnimated   (cond 0100030000000000004000000000000000000000000000ff)
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
    // --- fragment: workaroundForATIShaderCompilerBug   (cond 0100030000000000004000000000000000000000000000ff)
    // Apparently if we don't send anything depending on this value
    // to an interpolator, all of Current.color gets optimized out
    // of the shader, and so all the camerafacing stuff gets thrown out.
    // Yay!
    Current.texcoord<t0> = Current.color;
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: simImpostorMinSpec   (cond 0000000000000000000000000000000000000000000000ff)
    float3 clipPosition = In.texcoord<t1>.xyz;
    float3 vertexNormal = In.texcoord<t2>.xyz;
    clip(float4(1 + clipPosition.xy, 1 - clipPosition.xy));
    float4 texColor = tex2D(Sampler<s0>, In.texcoord<t0>.xy);
    Current.color.rgba = texColor;
    // --- fragment: workaroundForATIShaderCompilerBug   (cond 0100030000000000004000000000000000000000000000ff)
}
