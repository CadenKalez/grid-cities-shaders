// Material shader: SurfaceRockShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mScaleAndBias1; float4 mScaleAndBias2; } terrainSurfaceInfoVS;
sampler HeightMap : register(s0);
sampler ThicknessMap : register(s1);
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: surfaceVS   (cond 0000000000000000000000000000000000000000000000ff)
    {
    Current.texcoord0 = Current.position.xyxy / 1024;  
    Current.texcoord0 = 0.5 * (Current.texcoord<t0> + 1);
    Current.texcoord1 = float4( Current.normal.xyz, 0 );
    Current.texcoord2.xyz = Current.position.xyz;
    Current.texcoord3.xyz = Current.normal.xyz;  
    float2 uv1 = Current.position.xy;
    uv1 /= 2048.0;
    uv1 += 0.5;
    uv1 = saturate(uv1);
    float height = tex2Dlod(HeightMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048 - 1024;
    float thickness = tex2Dlod(ThicknessMap, float4(uv1.x, uv1.y, 0, 0)).x * 2048;
    Current.texcoord2.w = height;     
    Current.texcoord3.w = thickness;  
    Current.position.z += height;
    }
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 shCoeffs[9];
uniform float4 worldCameraDirection;
uniform struct { float4 mColor; float4 mReflectionParams; } rockStrataInfoPS;
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
sampler NormalMap : register(s0);

void main_pixel()
{
    // --- fragment: strataRockPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 pos = float4(In.texcoord2.xyz, 1);
    float3 bumpNormal = tex2D(NormalMap, In.texcoord<t0>.xy).xyz * 2.0 - 1.0;  
    clip(In.texcoord3.w-4.0);  
    float3 shDiffuse;
    float3 shSpec;
    float specE = 20;
    float gloss = 0.08;
    SHDiffSpec9(bumpNormal.xyz, shDiffuse, shSpec);
    float3 shade = shDiffuse * rockStrataInfoPS.mColor.rgb;
    Current.color.rgb = shade;
    Current.color.a = 1;
}
