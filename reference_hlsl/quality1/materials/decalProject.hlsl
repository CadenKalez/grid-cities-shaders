// Material shader: decalProject
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 SkinBones[(192)];
uniform float4x4 worldToClip;
uniform float4x3 cameraToWorld;

void main_vertex()
{
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
    // --- fragment: decalMaterialInfo   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = Current.indices.yzw * (1.0 / 255.0);
}

//==============================================================================
// PIXEL SHADER  (6 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 renderTargetInfo0;
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
uniform float4 viewFarCorners[4];

void main_pixel()
{
    // --- fragment: depthInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texXform = In.texcoord<t0>;
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
    // --- fragment: decalMaterialInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float4 decalMaterialInfo = In.texcoord<t0>;
    // --- fragment: decalOpacity   (cond 0000000000000000000000000000000000000000000000ff)
    // Relies on float4 decalMaterialInfo
    Current.color.a *= decalMaterialInfo.x;
}
