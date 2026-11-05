// Shader fragment  [PS slot 239]  building4ClipAndReliefMapPS

// ---- declarations / helper functions ----
static const float kReliefDepth = 0.1;
static const float kMaxConeRatio = 0.5;
float2 reliefMap(float2 tc, float3 ds, float4 tcxform, float flatDepth,
int coneSearchSteps, int binarySearchSteps,
float2 uv_ddx, float2 uv_ddy)
{
ds.xy = -ds.xy;
ds.z *= 1.0 / kReliefDepth;
ds *= (1.0/ds.z);
tc -= ds.xy * flatDepth;
float3 s = float3(tc,0);
float dsRat = length(ds.xy * tcxform.xy); // texture-space version of cone -- TODO: verify this is correct!
float dFinal = 0;
for(int i=0; i<coneSearchSteps; i++) {                    // 10 (11) cycle loop
float2 texcoord = saturate(s.xy) * tcxform.xy + tcxform.zw; // mov_sat, mad
float4 shaderTexel = tex2Dgrad(shaderMapSampler, texcoord, uv_ddx, uv_ddy);           // texld
float h = shaderTexel.x;                                    // (free)
float cRat = shaderTexel.y * kMaxConeRatio;                 // (free if kMaxConeRatio is 1, otherwise mul)
float step = saturate(h - s.z);                             // add_sat
float d = (cRat*step)/(dsRat+cRat);                         // mul, add, rcp, mul
dFinal = (step > 0) ? d : dFinal;                           // cmp
s = s + ds*d;                                               // mad
}
// binary search
ds *= dFinal;
s = s - ds;
for(int j=0; j<binarySearchSteps; j++) {                  // 7 cycle loop
ds *= 0.5;                                                  // mul
float2 texcoord = saturate(s.xy) * tcxform.xy + tcxform.zw; // mov_sat, mad
float4 shaderTexel = tex2Dgrad(shaderMapSampler, texcoord, uv_ddx, uv_ddy);           // texld
float h = shaderTexel.x;                                    // (free)
float3 step = ((h - s.z) >= 0) ? ds : -ds;                  // add, cmp
s = s + step;                                               // add
}
return s.xy;
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
float4 baseTintValues = tex2Dgrad(tintMapSampler, baseUv, uv_ddx, uv_ddy);
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
