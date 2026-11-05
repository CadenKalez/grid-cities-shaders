// Shader fragment  [VS slot 245]  treeParticleForestTransformVS

// ---- uniform parameters ----
uniform struct { float4 texXform; float4 cardData; float4 cardDepth; } impostorParticles[64];   // reg-meta 02c402c400c0000000000008
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

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
// Get information for this corner of the quad
float2 origQuadCorner = vtxInfo[int(cornerData.x)] * drawQuad; 
float2 quadCorner = origQuadCorner;
float3 camMovement = float3(0, 0, 0);
if(false)  
{
camMovement = CalculateTreeWindAnimation(float2(position.x, quadCorner.y));
}
// Get direction for offset into texture xform
float direction = modelData.z;
// Get model index and per-model data
int modelIdx = int(modelData.y);
float4 texXform = impostorParticles[modelIdx].texXform;
float4 cardData = impostorParticles[modelIdx].cardData;
float4 cardDepth = impostorParticles[modelIdx].cardDepth;
// Shrink the card height based upon distance from camera.
float fadeValue = 1.0f - GetFadeValue( position, worldCameraPosition.xyz );
quadCorner.y *= saturate( GetCameraDirFade( worldCameraDirection.xyz ) + fadeValue );
// Offset in camera space
float3 camOffset = float3(cardData.xy + cardData.zw * quadCorner, cardDepth.x) * scale;
// Get clip space position of quad corner
float4 pPos = CalculateFinalPosition(position, camOffset, cardDepth);
// Offset into atlas by facing
texXform.x += direction * texXform.z;
// Get UV
float2 uv = texXform.xy + texXform.zw * origQuadCorner;
Current.position = pPos;
Current.texcoord<t0> = float4(uv, modelData.x, 0.0f);
Current.texcoord<t1> = float4(position,1);
 Current.texcoord<t0>.y = 1 - Current.texcoord<t0>.y; 
// Color copied automatically
