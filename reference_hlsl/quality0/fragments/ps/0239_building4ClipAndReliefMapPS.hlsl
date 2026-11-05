// Shader fragment  [PS slot 239]  building4ClipAndReliefMapPS

// ---- declarations / helper functions ----
static const float kReliefDepth = 0.1;
static const float kMaxConeRatio = 0.5;
float2 reliefMap(float2 tc, float3 ds, float4 tcxform, float flatDepth,
int ignore1, int ignore2,
float2 uv_ddx, float2 uv_ddy)
{
return tc;
}
static const int kConeSteps = 8;
static const int kBinarySteps = 2;
static const int kCullDistanceSq = 160000;
static const int kFlatLevelInt = 23;
static const float kFlatLevel = kFlatLevelInt / 255.0;

// ---- fragment body (spliced into the generated main()) ----
float2 uv_ddx = ddx(uv * regionXform.xy);
float2 uv_ddy = ddy(uv * regionXform.xy);
float2 baseUv = frac(uv) * regionXform.xy + regionXform.zw;
float4 baseTintValues = tex2D(tintMapSampler, baseUv);
Current.color.a = (baseTintValues.a - 0.5 < 0)?0:1;
float3 reliefEyeDir = eyeDir;
reliefEyeDir.xy /= abs(regionXform2.xy);  
// handle padding and tiling
uv2 = frac(uv2);
uv2 = uv2 * (1 + tilePadding) - (tilePadding * .5);
float2 reliefSrc = uv2;
float distFromPixel = dot(eyeDir.xyz,eyeDir.xyz);
float2 relief_tc;
if( distFromPixel>kCullDistanceSq )
relief_tc = reliefSrc;
else
relief_tc = reliefMap(reliefSrc, reliefEyeDir, regionXform2, kFlatLevel, kConeSteps, kBinarySteps, uv_ddx, uv_ddy);
float4 tcBoundary = float4(0 - relief_tc.xy, relief_tc.xy - 1);
float outsideTile = dot(saturate(tcBoundary), float4(1, 1, 1, 1));  // we really just care about this being > 0, the magnitude is irrelevant
relief_tc = relief_tc * regionXform2.xy + regionXform2.zw;
