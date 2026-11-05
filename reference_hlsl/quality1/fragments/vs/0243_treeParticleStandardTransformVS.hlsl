// Shader fragment  [VS slot 243]  treeParticleStandardTransformVS

// ---- uniform parameters ----
uniform struct { float4 texXform; float4 cardData; float4 cardDepth; } impostorParticles[64];   // reg-meta 02c402c400c0000000000008
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000

// ---- declarations / helper functions ----
static const bool kFixParallax = (1) != 0;
static const float kZBiasFactor = -0.00001;
static const float2 vtxInfo[4] = {
float2(0,0),
float2(0,1),
float2(1,1),
float2(1,0)
};
float3 CalculateTreeWindAnimation(float2 animInfo)
{
float kWaveLength = 10;
float kWaveZero = 5;
float kAnimSpeed = 1;
float kMaxAmplitude = 8;
float wavePos = gameInfo.x + animInfo.x * 0.005;
float animTime = frac(wavePos * (1.0 / (kWaveLength + kWaveZero)));
float animScale = saturate(1 - animTime * ((kWaveLength + kWaveZero) / kWaveLength)) * kMaxAmplitude;
animTime *= (kWaveLength + kWaveZero) * kAnimSpeed;
float waveAmount = sin(sqrt(animTime)) * animScale * animInfo.y;
return mul(float3(-1,0,0), make_float3x3(worldToCamera)) * waveAmount;
}
float4 CalculateFinalPosition(float3 worldPos, float3 camOffset, float4 cardDepth)
{
float3 cPos = mul(float4(worldPos, 1), worldToCamera) + camOffset;
float4 pPos = mul(float4(cPos, 1), cameraToClip);
if ( kFixParallax )
{
float4 offsetW = mul(float4(0,0,1,0), cameraToClip);
pPos.xy -= pPos.w * offsetW.xy;
pPos.xy *= pPos.w / (pPos.w - camOffset.z * offsetW.w);
pPos.xy += pPos.w * offsetW.xy;
}
pPos.z += cardDepth.y * pPos.w * kZBiasFactor;
return pPos;
}

// ---- fragment body (spliced into the generated main()) ----
float2 cornerData = In.texcoord0.xy;
float3 modelData = In.normal.xyz;
float3 position = modelPosition.xyz;
float2 quadCorner = vtxInfo[int(cornerData.x)];
float3 camMovement = float3(0, 0, 0);
if(false)  
{
camMovement = CalculateTreeWindAnimation(float2(position.x, quadCorner.y));
}
float direction = modelData.z;
float scale = modelData.x;
int modelIdx = int(modelData.y);
float4 texXform = impostorParticles[modelIdx].texXform;
float4 cardData = impostorParticles[modelIdx].cardData;
float4 cardDepth = impostorParticles[modelIdx].cardDepth;
float3 camOffset = float3(cardData.xy + cardData.zw * quadCorner, cardDepth.x) * scale;
float4 pPos = CalculateFinalPosition(position, camOffset, cardDepth);
texXform.x += direction * texXform.z;
float2 uv = texXform.xy + /*float2(0/512.0,-0.5/512.0) +*/ texXform.zw * quadCorner;
Current.position = pPos;
Current.texcoord<t0> = float4(uv, quadCorner);
Current.texcoord<t1> = float4(position,1);
 Current.texcoord<t0>.y = 1 - Current.texcoord<t0>.y;
