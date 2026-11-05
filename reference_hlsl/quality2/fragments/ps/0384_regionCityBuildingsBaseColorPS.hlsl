// Shader fragment  [PS slot 384]  regionCityBuildingsBaseColorPS

// ---- declarations / helper functions ----
static const bool kBilinearPaletteSample = true;
static const bool kOptimizedPaletteSample = true;
static const int2  kPaletteSize = int2(256, 8);
static const float2 kPaletteInvSize = 1.0 / kPaletteSize;
static const float kSurfacePalV = 1.0 - kPaletteInvSize.y;
void BuildingPaletteSamplePoint(float palU, float palV, float3 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(kOptimizedPaletteSample)
{
float subsample_u = tintValues.r;
float subsample_v = tintValues.g;
float r_g_b = tintValues.b * 2;
tintValues.b = subsample_u * r_g_b;
float r_g = r_g_b - tintValues.b;
tintValues.g = subsample_v * r_g;
tintValues.r = r_g - tintValues.g;
}
static const float2 kUvOffset_r = float2(0.25, 0.25) * kPaletteInvSize;
static const float2 kUvOffset_g = float2(0.25, 0.75) * kPaletteInvSize;
static const float2 kUvOffset_b = float2(0.75, 0.25) * kPaletteInvSize;
float4 uvsBase = float4(palU, palV, palU, kSurfacePalV);
float4 uvs_r = uvsBase + kUvOffset_r.xyxy;
float4 uvs_g = uvsBase + kUvOffset_g.xyxy;
float4 uvs_b = uvsBase + kUvOffset_b.xyxy;
// get tint matrices
float3x4 colorMatrix;
colorMatrix[0] = tex2D(tintPaletteSampler, uvs_r.xy);
colorMatrix[1] = tex2D(tintPaletteSampler, uvs_g.xy);
colorMatrix[2] = tex2D(tintPaletteSampler, uvs_b.xy);
colorValues = mul(tintValues.rgb, colorMatrix);
float3x4 surfaceMatrix;
surfaceMatrix[0] = tex2D(tintPaletteSampler, uvs_r.zw);
surfaceMatrix[1] = tex2D(tintPaletteSampler, uvs_g.zw);
surfaceMatrix[2] = tex2D(tintPaletteSampler, uvs_b.zw);
surfaceValues = mul(tintValues.rgb, surfaceMatrix);
}
void BuildingPaletteSampleBilerp(float palU, float palV, float3 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(!kOptimizedPaletteSample)
{
float r_g = tintValues.r + tintValues.g;
float r_g_b = (tintValues.r + tintValues.g + tintValues.b);
float subsample_u = r_g_b > 0 ? (tintValues.b / r_g_b) : 0.5;
float subsample_v = r_g > 0 ? (tintValues.g / r_g) : 0.5;
tintValues.r = subsample_u;
tintValues.g = subsample_v;
tintValues.b = saturate(r_g_b * 0.5);
}
static const float2 kSubsampleScale = kPaletteInvSize * 0.5;
static const float2 kSubsampleOffset = kPaletteInvSize * 0.25;
float2 subsample = tintValues.rg * kSubsampleScale + kSubsampleOffset;
float4 uvsBase = float4(palU, palV, palU, kSurfacePalV);
float4 adjustedUV = subsample.xyxy + uvsBase;
colorValues   = tex2D(tintPaletteSampler, adjustedUV.xy) * (tintValues.b * 2);
surfaceValues = tex2D(tintPaletteSampler, adjustedUV.zw) * (tintValues.b * 2);
}
void BuildingPaletteSample(float palU, float palV, float4 tintValues, out float4 colorValues, out float4 surfaceValues)
{
if(kBilinearPaletteSample)
{
BuildingPaletteSampleBilerp(palU, palV, tintValues.xyz, colorValues, surfaceValues);
}
else
{
BuildingPaletteSamplePoint(palU, palV, tintValues.xyz, colorValues, surfaceValues);
}
}
float FastNoise(float3 seed)
{
seed *= float3(78.233, 12.9898, 43758.5453);
seed += float3(0.819 * 78.233, 0.819 * 12.9898, 0.819 * 43758.5453);
float random = frac(seed.z * frac(seed.x * frac(seed.y)));
return random;
}
static const int    kNumPaletteEntries    = 256;
static const float  kInvNumPaletteEntries = 1.0f / kNumPaletteEntries;
static const float3 kZero3                = float3( 0.0f, 0.0f, 0.0f );

// ---- fragment body (spliced into the generated main()) ----
// sample textures
float4 facadeTintValues = tex2Dgrad( tintMapSampler,    relief_tc, uv_ddx2, uv_ddy2 );
float4 shaderMapBase    = tex2Dgrad( shaderMapSampler,  baseUv,    uv_ddx1, uv_ddy1 );
float4 shaderMapTop     = tex2Dgrad( shaderMapSampler,  relief_tc, uv_ddx2, uv_ddy2 );
facadeTintValues.a = ( outsideTile > 0 ) ? 0 : facadeTintValues.a;
float4 shaderMapSampled = lerp( shaderMapBase, shaderMapTop, facadeTintValues.a );
// TODO: actually fix up color variations. Pretty sure we'll need it as some
//       point.
// tint
float4 tintBase;
float4 specBase;
BuildingPaletteSample( palU, 0.0f, float4( baseTintValues.rgb, 0.0f ), tintBase, specBase );
float4 tintTop;
float4 specTop;
BuildingPaletteSample( palU2, 0.0f, float4( facadeTintValues.rgb, 0.0f ), tintTop, specTop );
float4 tintResult = lerp( tintBase, tintTop, facadeTintValues.a );
float2 interiorUv = uv * regionXform.xy * interiorRoomInvSize;
int2 interiorElem = int2( floor( interiorUv ) );
float random      = FastNoise( float3( interiorElem, 0.213425435f ) );
float interior         = shaderMapSampled.a > 0.8f ? 0.0f : 1.0f;
float interiorLighting = random > interiorLightTime ? interior : 0.0f;
float3 finalColor = lerp( tintResult.rgb, kZero3, interior );
// output
Current.color = float4( finalColor, 1.0f );
