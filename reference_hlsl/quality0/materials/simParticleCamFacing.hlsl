// Material shader: simParticleCamFacing
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 cameraToClip;
uniform float4x3 worldToCamera;
uniform struct { float4 texXform; float4 cardData; float4 cardDepth; } impostorParticles[64];
uniform float4 impostorAttachments[32];
uniform float4 impostorAngles[4];
static const bool kEnableDepthSprite = (0) != 0;
static const bool kFixParallax = (1) != 0;
static const float kZBiasFactor = -0.00001;
static const float2 vtxInfo[4] = {
float2(0,0),
float2(0,1),
float2(1,1),
float2(1,0)
};
uniform float4 worldCameraDirection;
uniform float4 shCoeffs[9];
uniform float4 worldCameraDirection;
const static float kSH_A1 = 2.0 / 3.0;
const static float kSH_A2 = 1.0 / 4.0;
const static float kSH_A3 = 0;
const static float kSH_A4 = -1.0 / 24.0;
const static float kDefaultGloss = 0.00;
const static float kGlossyMax    = 1.0; // threshold at which glossy maxes out
const static float kCelOutlineThreshold        = 0.25;
const static float kCelOutlineThresholdRange   = 0.075;
const static float kCelStrength                = 0.3;
const static float kSpecExponentMaxValue = 60.0;
const static bool kSaveInstructions = false;
void SHLighting
(
float3      normal,
float3      viewVector,
out float3  shColorDiff,
out float3  shColorSpec,
bool        translucency
)
{
float3 shColor;
float3 x0 = normal;
float3 x1 = x0 * x0;
float3 x2 = x0 * x0.yzx;
shColorDiff = shCoeffs[0].xyz;
shColorSpec = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
shColor  = shCoeffs[4].xyz  * x2.x;  // x * y
shColor += shCoeffs[5].xyz  * x2.y;  // y * z
shColor += shCoeffs[6].xyz  * (3 * x1.z - 1);
shColor += shCoeffs[7].xyz  * x2.z;  // z * x
shColor += shCoeffs[8].xyz  * (x1.x - x1.y);
shColor *= kSH_A2;
shColorDiff += shColor;
float3 reflectV;
if (translucency)
reflectV = -normal;
else
reflectV = reflect(viewVector, normal);
x0 = reflectV;
x1 = x0 * x0;
x2 = x0 * x0.yzx;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor += shCoeffs[4].xyz  * x2.x;  // x * y
shColor += shCoeffs[5].xyz  * x2.y;  // y * z
shColor += shCoeffs[6].xyz  * (3 * x1.z - 1);
shColor += shCoeffs[7].xyz  * x2.z;  // z * x
shColor += shCoeffs[8].xyz  * (x1.x - x1.y);
shColorSpec += shColor;
}
void SHDiffSpec9
(
float3      normal,
out float3  shColorDiff,
out float3  shColorSpec
)
{
SHLighting(normal, worldCameraDirection.xyz, shColorDiff, shColorSpec, false);
}

void main_vertex()
{
    // --- fragment: simParticleTransformVS   (cond 0000000000000000000000000000000000000000000000ff)
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
    // --- fragment: impostorParticleLightVS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 worldNormal = normalize(-worldCameraDirection.xyz);
    float3 shColorDiff, shColorSpec;
    SHDiffSpec9(worldNormal, shColorDiff, shColorSpec);
    Current.texcoord<t0> = shColorDiff;
    Current.texcoord<t1> = shColorSpec;
    Current.texcoord<t2> = position.xyz;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
float4 GetDeferredLight( float2 screenUV )
{
return float4(0,0,0,0);
}
float3 GetDeferredNormal( float2 screenUV )
{
return float3(0,0,1);
}
float4 GetDeferredNormalAndSpec( float2 screenUV )
{
return float4(0,0,1,1);
}
uniform float4 worldCameraDirection;
uniform float4 screenInfo;
uniform float4 samplerInfo0;
sampler sourceTex          : register(s0);
sampler offscreenNormalTex : register(s1);
sampler bodyPaletteTex     : register(s2);
sampler clothesPaletteTex  : register(s3);
static const bool kCheapSims = true;
static const bool kAllowMip = false;
static const bool kReallyExpensive = false;
void swap(inout float4 a, inout float4 b)
{
float4 temp = a;
a = b;
b = temp;
}
void merge(inout float4 a, inout float4 b)
{
a.x = (a.x * a.z + b.x * b.z) / (a.z + b.z);
a.z += b.z;
b.z = 0;
}
void FindPalEntry(float2 uv, out float palV, out float amount, out float alpha, out float4 debug)
{
const float2 kTexSize = samplerInfo0.xy;
const float2 kInvTexSize = samplerInfo0.zw;
if(kCheapSims

)
{
float4 tex;
if(kAllowMip)
tex = tex2D(sourceTex, uv);
else
tex = tex2Dlod(sourceTex, float4(uv, 0, 0));
amount = tex.r;
palV = tex.g;
alpha = tex.a;
debug = float4(0, 0, 0, 0);
return;
}
uv -= 0.5 * kInvTexSize;
float2 mid = fmod(uv, kInvTexSize);
float2 base = uv - mid;
float4 coords = float4(base, base+kInvTexSize);
float4 weightInfo = float4(mid, kInvTexSize - mid);
float4 weightX = float4(weightInfo.xxzz) * kTexSize.x;
float4 weightY = float4(weightInfo.ywyw) * kTexSize.y;
float4 weights = weightX * weightY;
float4 texBB, texBN, texNB, texNN;
if(kAllowMip)
{
texBB = tex2D(sourceTex, coords.xy);
texBN = tex2D(sourceTex, coords.xw);
texNB = tex2D(sourceTex, coords.zy);
texNN = tex2D(sourceTex, coords.zw);
}
else
{
texBB = tex2Dlod(sourceTex, float4(coords.xy, 0, 0));
texBN = tex2Dlod(sourceTex, float4(coords.xw, 0, 0));
texNB = tex2Dlod(sourceTex, float4(coords.zy, 0, 0));
texNN = tex2Dlod(sourceTex, float4(coords.zw, 0, 0));
}
float4 alphas = float4(texNN.a, texNB.a, texBN.a, texBB.a);
float4 pals   = float4(texNN.g, texNB.g, texBN.g, texBB.g);
float4 amts   = float4(texNN.r, texNB.r, texBN.r, texBB.r);
alpha = dot(alphas, weights);
weights = saturate(weights - (1 - alphas));
 float4 cmp1 = weights.xyxy > weights.zwzw ? float4(weights.xy, pals.xy) : float4(weights.zw, pals.zw);

float2 cmp2 = cmp1.x > cmp1.y ? cmp1.xz : cmp1.yw;
float weight = cmp2.x;
float p = cmp2.y;
weights = saturate(weights - (abs(pals - p) * 1024));
weights /= dot(float4(1, 1, 1, 1),weights);
debug = weights;
palV = p;
amount = dot(amts, weights);
}
uniform float4 gameInfo;

void main_pixel()
{
    // --- fragment: deferredDiffuseDisabled   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: simParticleLightMinSpecPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
    float bodyPalU = In.color.x;
    float clothesPalU = In.color.y;
    float2 uv = In.texcoord<t0>.xy;
    float2 quadCorner = In.texcoord<t0>.zw;
    float3 shColorDiff = In.texcoord<t1>.xyz;
    float3 shColorSpec = In.texcoord<t2>.xyz;
    float palV;
    float aoFactor;
    float alpha;
    float4 debug;
    FindPalEntry(uv, palV, aoFactor, alpha, debug);
    if(kCheapSims
    
    )
    {
    clip( alpha );
    }
    else
    {
    clip(alpha - 0.3);
    }
    float4 bodyColor = tex2D(bodyPaletteTex, float2(bodyPalU, palV));
    float4 clothesColor = tex2D(clothesPaletteTex, float2(clothesPalU, palV));
    float3 tintColor = lerp(bodyColor.rgb, clothesColor.rgb, clothesColor.a);
    // light combine
    Current.color.rgb = (tintColor * (shColorDiff + shColorSpec) ) * aoFactor;
    Current.color.a =  alpha;
    // --- fragment: simZombiePS   (cond 0702c90001000000000000000000000000000000000000ff)
    const float3 kBodyEmissive = float3(1,8,0);
    const float3 kClothesEmissive = float3(0,0,0);
    float3 glowAmount = lerp(kBodyEmissive, kClothesEmissive, clothesColor.a);
    Current.color.rgb += glowAmount;
}
