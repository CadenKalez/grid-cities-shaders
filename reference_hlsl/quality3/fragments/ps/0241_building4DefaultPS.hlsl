// Shader fragment  [PS slot 241]  building4DefaultPS

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
static const float kBuildingSpecOverdrive = 2.000000;
static const float kBuildingInteriorMapSelfLightMax = 16.000000;

// ---- fragment body (spliced into the generated main()) ----
// sample textures
float4 facadeTintValues = tex2Dgrad(tintMapSampler,    relief_tc,  uv_ddx, uv_ddy);
float4 normalMapBase    = tex2Dgrad(normalMapSampler,  baseUv,     uv_ddx, uv_ddy);
float4 normalMapTop     = tex2Dgrad(normalMapSampler,  relief_tc,  uv_ddx, uv_ddy);
float4 shaderMapBase    = tex2Dgrad(shaderMapSampler,  baseUv,     uv_ddx, uv_ddy);
float4 shaderMapTop     = tex2Dgrad(shaderMapSampler,  relief_tc,  uv_ddx, uv_ddy);
half4 interiorMap = tex2D(interiorMapSampler, interior_tc);
facadeTintValues.a = (outsideTile > 0) ? 0 : facadeTintValues.a;
// Is normal lerp good enough?  Should renormalize?
half4 shaderMapSampled = lerp(shaderMapBase, shaderMapTop, facadeTintValues.a);
half4 tintBase;
half4 specBase;
BuildingPaletteSample(palU, buildingVariation, half4(baseTintValues.rgb, 0), tintBase, specBase);
half4 tintTop;
half4 specTop;
BuildingPaletteSample(palU2, buildingVariation, half4(facadeTintValues.rgb, 0), tintTop, specTop);
half4 tintResult = lerp(tintBase, tintTop, facadeTintValues.a);
half4 specResult = lerp(specBase, specTop, facadeTintValues.a);
// using interiorThresholds.z is a hack to turn the emissive off for unpowered buildings;
// powered buildings always have .z = 1, unpowered/abandoned buildings have .z = 0.
half artistEmissive = specResult.x * specResult.x * interiorThresholds.z;
half3 tintColor = tintResult.rgb;
half artistOpacity = shaderMapSampled.a;
// apply lighting/ao
half3 exteriorColor = tintColor * (shColorDiff + artistEmissive*256) + tintColor * shColorSpec;
half3 interiorColor = interiorMap.rgb * (shColorDiff + interiorMap.aaa * kBuildingInteriorMapSelfLightMax + shColorSpec);
// combine colors
half3 finalColor = lerp(interiorColor, exteriorColor, artistOpacity);
// output
Current.color.rgb = finalColor;
