// Shader fragment  [PS slot 364]  treeParticleForestHSVTweakPS

// ---- uniform parameters ----
uniform struct { float4 mHsvMin; float4 mHsvDiff; } terrainForestInfoPS[4];   // reg-meta 029902990008000000000008

// ---- declarations / helper functions ----
float3 CalculateHSVTweakedColor(float3 hsvParamModifiers, float3 diffuseColor)
{
static const float3 kHSVRangeMin = float3(-1 * 3.141592, 0, 0);
static const float3 kHSVRangeMax = float3(1 * 3.141592, 5, 2);
static const float3 kHSVRangeScale = kHSVRangeMax - kHSVRangeMin;
static const float3x3 yiqMat = float3x3(0.299, 0.587, 0.114, 0.596, -0.274, -0.321, 0.211, -0.523, 0.311);
static const float3x3 rgbMat = float3x3(1, 0.956, 0.621, 1, -0.272, -0.647, 1, -1.107, 1.705);
float3 hsvParams = hsvParamModifiers * kHSVRangeScale + kHSVRangeMin;
float kHueRot = hsvParams.r;
float kSatScale = hsvParams.g;
float kValScale = hsvParams.b;
float kHueS, kHueC;
sincos(kHueRot, kHueS, kHueC);
float3 yiqColor = mul(yiqMat, diffuseColor);
yiqColor *= kValScale;
yiqColor.yz *= kSatScale;
yiqColor.yz = mul(float2x2(kHueC, -kHueS, kHueS, kHueC), yiqColor.yz);
return mul(rgbMat, yiqColor);
}

// ---- fragment body (spliced into the generated main()) ----
int treeType = int( floor( type ) );
float3 treeParams = terrainForestInfoPS[ treeType ].mHsvMin.xyz + terrainForestInfoPS[ treeType ].mHsvDiff.xyz * In.color.rgb;
diffuseMapSample.rgb = CalculateHSVTweakedColor(treeParams, diffuseMapSample.rgb);
