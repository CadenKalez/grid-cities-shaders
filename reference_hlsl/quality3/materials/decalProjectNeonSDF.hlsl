// Material shader: decalProjectNeonSDF
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (6 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 SkinBones[(192)];
uniform float4x4 worldToClip;
uniform float4 customParams[16];
uniform float4x3 cameraToWorld;

void main_vertex()
{
    // --- fragment: decalMaterialData4SDFSwizzle   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = float4(In.texcoord4.x,In.texcoord5.x,In.texcoord6.x,In.texcoord7.x);
    Current.color1 = float4(In.texcoord4.y,In.texcoord5.y,In.texcoord6.y,In.texcoord7.y);
    Current.texcoord<t0> = float4(In.texcoord4.z,In.texcoord5.z,In.texcoord6.z,In.texcoord7.z);
    Current.texcoord<t1> = float4(In.texcoord4.w,In.texcoord5.w,In.texcoord6.w,In.texcoord7.w);
    // --- fragment: depthInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float hw = Current.position.w;
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    int xformIdx = toInt(Current.indices.x);
    float3x4 modelToWorld = float3x4(SkinBones[xformIdx + 0], SkinBones[xformIdx + 1], SkinBones[xformIdx + 2]);
    float3x4 modelToTexture = float3x4(In.texcoord1, In.texcoord2, In.texcoord3);
    float3 modelPos = Current.position.xyz;
    float3 worldPos = mul(modelToWorld, float4(modelPos,1));
    Current.position = mul(float4(worldPos,1), worldToClip);
    Current.texcoord<t0> = In.texcoord0;
    // --- fragment: decalMaterialInfoWithObjectData   (cond 0000000000000000000000000000000000000000000000ff)
    int realXformIdx = xformIdx / 3; // Why did I premultiply these again?  So silly.
    int customParamIndex = realXformIdx / 4;
    int customParamCpt = realXformIdx % 4;
    Current.texcoord<t0>.xyz = Current.indices.yzw * (1.0 / 255.0);
    Current.texcoord<t0>.w = customParams[customParamIndex][customParamCpt];
    // --- fragment: decalProject   (cond 0000000000000000000000000000000000000000000000ff)
    float3x4 cameraToWorldT = transpose(cameraToWorld);
    float4x4 cameraToWorld44 = float4x4(
    cameraToWorldT[0],
    cameraToWorldT[1],
    cameraToWorldT[2],
    float4(0,0,0,1));
    float invSqrMWScale = 1.0 / dot(modelToWorld[0].xyz, modelToWorld[0].xyz);
    float3x3 modelToWorldT33 = transpose(make_float3x3(modelToWorld)) * invSqrMWScale;
    float3   newTranslation  = -mul(modelToWorldT33, float3(modelToWorld[0].w, modelToWorld[1].w, modelToWorld[2].w));
    float4x4 worldToModel = float4x4(
    float4(modelToWorldT33[0], newTranslation.x),
    float4(modelToWorldT33[1], newTranslation.y),
    float4(modelToWorldT33[2], newTranslation.z),
    float4(0,0,0,1));
    float4x4 cameraToModel = mul(worldToModel, cameraToWorld44);
    float4x4 cameraToTexture = mul(float4x4(modelToTexture[0], modelToTexture[1], modelToTexture[2], float4(0,0,0,1)), cameraToModel);
    Current.texcoord<t0> = cameraToTexture[0];
    Current.texcoord<t1> = cameraToTexture[1];
    Current.texcoord<t2> = cameraToTexture[2];
    // --- fragment: decalNUS   (cond 0000000000000000000000000000000000000000000000ff)
    {
    float3 NUSTextureSqr;
    NUSTextureSqr.x = dot(modelToTexture[0].xyz, modelToTexture[0].xyz);
    NUSTextureSqr.y = dot(modelToTexture[1].xyz, modelToTexture[1].xyz);
    NUSTextureSqr.z = dot(modelToTexture[2].xyz, modelToTexture[2].xyz);
    float uniformSqr = dot(modelToWorld[0].xyz, modelToWorld[0].xyz);
    Current.texcoord<t0>.xyz = sqrt(NUSTextureSqr * uniformSqr);
    }
}

//==============================================================================
// PIXEL SHADER  (8 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 renderTargetInfo0;
extern uniform sampler normalMap : register(s14);
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
uniform float4 viewFarCorners[4];
uniform float4 gameInfo;

void main_pixel()
{
    // --- fragment: decalMaterialData4   (cond 0000000000000000000000000000000000000000000000ff)
    float4 decalMaterialData[4] = { In.color, In.color1, In.texcoord<t0>, In.texcoord<t1> };
    // --- fragment: depthNormalInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    float3 worldNormalPack = tex2D(normalMap, screenUV).xyz;
    float3 worldNormal = normalize(2 * worldNormalPack - 1);
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texXform = In.texcoord<t0>;
    // --- fragment: decalMaterialInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float4 decalMaterialInfo = In.texcoord<t0>;
    // --- fragment: decalProject   (cond 0000000000000000000000000000000000000000000000ff)
     float screenV = screenUV.y;
    
    float3 farPlaneXYZ =
    lerp(
    lerp(viewFarCorners[1].xyz, viewFarCorners[3].xyz, screenUV.x),
    lerp(viewFarCorners[0].xyz, viewFarCorners[2].xyz, screenUV.x),
    screenV);
    float3 camXYZ = farPlaneXYZ * depth;
    float4x4 camToTexture = float4x4(In.texcoord<t0>, In.texcoord<t1>, In.texcoord<t2>, float4(0,0,0,1));
    float3 texturePosition = mul(camToTexture, float4(camXYZ, 1)).xyz;
    float2 uvOrig = texturePosition.xy * -0.5 + 0.5;
    float2 uv = uvOrig * texXform.xy + texXform.zw;
    float4 decalTexture = tex2D(Sampler<s0>, uv);
    Current.color = decalTexture;
    // --- fragment: decalClip   (cond 0000000000000000000000000000000000000000000000ff)
    clip(1 - abs(texturePosition));
    // --- fragment: decalAnimateSDF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 animResults;
    float4 useV;
    {
    float4 animParameters = decalMaterialData[3];
    useV = float4(animParameters.x > 0 ? 0 : 1, animParameters.y > 0 ? 0 : 1, animParameters.z > 0 ? 0 : 1, animParameters.w > 0 ? 0 : 1);
    animParameters = abs(animParameters);
    animParameters += 0.0001; 
    float animSpeed = decalMaterialInfo.y;
    float animTime = frac(gameInfo.x * animSpeed + 0.9999);  
    float4 animOffsets = frac(animParameters);
    float4 animChunks = max(float4(1.0, 1.0, 1.0, 1.0), floor(animParameters));
    float4 compares = floor((animTime * 3 - animOffsets) * animChunks) * (1 / animChunks);
    float4 uvCompare = lerp(uvOrig.xxxx, uvOrig.yyyy, useV.xyzw);
    animResults = uvCompare - compares;
    }
    // --- fragment: decalLightSDF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 decalNUS = In.texcoord<t0>.xyz;
    float materialLightScale = decalMaterialInfo.x * 16.0 + 0.25;
    float sdfTextureLength = max(decalNUS.x, decalNUS.y);
    float sphereHeight = decalNUS.z;
    float hwRatio = sphereHeight * 0.5 / sdfTextureLength;
    float zScale = 1;
    if(hwRatio < 1)
    {
    hwRatio = 1;
    zScale = 1 / hwRatio;
    }
    float circleZ = texturePosition.z;  // distance from center of texture
    circleZ *= zScale;
    float4 sdfDists = Current.color;
    float kMaskCenter = 0.5;
    float4 circleDists = saturate(1 - sdfDists * (1.0 / kMaskCenter)) * hwRatio;
    float4 sphereDistsSqr = circleDists*circleDists + circleZ*circleZ;
    float4 animEdge = max(animResults, 0.0);
    float lerpXParam = sphereHeight * 0.5 / decalNUS.x;
    float lerpYParam = sphereHeight * 0.5 / decalNUS.y;
    float4 animRatio = lerp(float4(lerpXParam, lerpXParam, lerpXParam, lerpXParam), float4(lerpYParam, lerpYParam, lerpYParam, lerpYParam), useV.xyzw);
    sphereDistsSqr += animEdge * animEdge * animRatio * 32;
    float4 lightScales = saturate(1 - sqrt(sphereDistsSqr));
    lightScales *= lightScales;
    float3 lightColor = float3(0, 0, 0);
    for(int i = 0; i < 3; ++i)
    {
    // apply light
    lightColor[i] = materialLightScale * dot(decalMaterialData[i],lightScales);
    }
    // de-power
    lightColor *= decalMaterialInfo.w;
    Current.color.rgb = lightColor;
    Current.color.a = 0;
}
