// Shader fragment  [VS slot 251]  simParticleTransformVS

// ---- uniform parameters ----
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform struct { float4 texXform; float4 cardData; float4 cardDepth; } impostorParticles[64];   // reg-meta 02c402c400c0000000000008
uniform float4 impostorAttachments[32];   // reg-meta 02cd02cd0020000000000008
uniform float4 impostorAngles[4];   // reg-meta 02ce02ce0004000000000008

// ---- declarations / helper functions ----
static const bool kEnableDepthSprite = (0) != 0;
static const bool kFixParallax = (1) != 0;
static const float kZBiasFactor = -0.00001;
static const float2 vtxInfo[4] = {
float2(0,0),
float2(0,1),
float2(1,1),
float2(1,0)
};

// ---- fragment body (spliced into the generated main()) ----
float2 cornerData = In.texcoord0.xy;
float3 modelData = In.normal.xyz;
float3 position = modelPosition.xyz;
float2 quadCorner = vtxInfo[int(cornerData.x)];
float direction = modelData.z;
float attachIdx = cornerData.y;
float3 attachOffset = float3(0, 0, 0);
if(attachIdx >= 0)
{
// get camera sincos to rotate offset
float4 anglesSinCos = impostorAngles[int(floor(direction * 0.5))];
float2 angleSinCos = (frac(direction * 0.5) > 0) ? anglesSinCos.zw : anglesSinCos.xy;
// get offset and rotate by angle z
attachOffset = impostorAttachments[int(attachIdx)].xyz;
attachOffset.xy = attachOffset.xy * angleSinCos.yy + attachOffset.yx * float2(-angleSinCos.x, angleSinCos.x);
// rotate into camera space
attachOffset = mul(attachOffset, make_float3x3(worldToCamera));
// don't modify z
if(!kEnableDepthSprite)
attachOffset.z = 0;
}
float scale = modelData.x;
int modelIdx = int(modelData.y);
float4 texXform = impostorParticles[modelIdx].texXform;
float4 cardData = impostorParticles[modelIdx].cardData;
float4 cardDepth = impostorParticles[modelIdx].cardDepth;
float3 camOffset = attachOffset + float3(cardData.xy + cardData.zw * quadCorner, cardDepth.x);
camOffset *= scale;
texXform.x += direction * texXform.z;
float3 cPos = mul(float4(position, 1), worldToCamera) + camOffset;
float4 pPos = mul(float4(cPos, 1), cameraToClip);
if(kFixParallax)
{
float4 offsetW = mul(float4(0,0,1,0), cameraToClip);
pPos.xy -= pPos.w * offsetW.xy;
pPos.xy *= pPos.w / (pPos.w - camOffset.z * offsetW.w);
pPos.xy += pPos.w * offsetW.xy;
}
pPos.z += cardDepth.y * pPos.w * kZBiasFactor;
float2 uv = texXform.xy + /*float2(0/512.0,-0.5/512.0) +*/ texXform.zw * quadCorner;
Current.position = pPos;
Current.texcoord<t0> = float4(uv, quadCorner);
 Current.texcoord<t0>.y = 1 - Current.texcoord<t0>.y;
