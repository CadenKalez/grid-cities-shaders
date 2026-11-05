// Shader fragment  [PS slot 375]  simParticleLightMinSpecPS

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 samplerInfo0;   // reg-meta 025e025e0001000000400000

// ---- declarations / helper functions ----
sampler sourceTex          : register(s0);
sampler offscreenNormalTex : register(s1);
sampler bodyPaletteTex     : register(s2);
sampler clothesPaletteTex  : register(s3);
static const bool kCheapSims = false;
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

// ---- fragment body (spliced into the generated main()) ----
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
