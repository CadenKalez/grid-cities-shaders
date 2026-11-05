// Shader fragment  [PS slot 177]  terrainDataViewCommonPS

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008
uniform struct { float4 mMapColor[2]; float4 mMapColorNegatives[2]; float4 mContourInfo[2]; float4 mTextureSize; } contourInfo;   // reg-meta 029202920007000000000008
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mNormalParams; float4 mColor; } terrainInfoPS;   // reg-meta 028202820004000000000008

// ---- declarations / helper functions ----
static const float4x4 kSplineMatrix = 1.0/6
* float4x4( 1,  4,  1,  0,
-3,  0,  3,  0,
3, -6,  3,  0,
-1,  3, -3,  1);
/*
static const float4x4 kSplineMatrix = 0.5
* float4x4( 0,  2,  0,  0,
-1,  0,  1,  0,
2, -5,  4, -1,
-1,  3, -3,  1 );
*/
float4 getK(float t)
{
float4 ts = float4(1, t, t*t, t*t*t);
return mul(ts, kSplineMatrix);
}
float2 lerpValues(float2 v)
{
float sum = v.x + v.y;
return float2(v.y / sum, sum);
}
float2 bicubic(sampler map, float2 uv, float2 texSize, float2 invTexSize)  // invTexSize = 1.0 / texSize
{
float2 texel = uv * texSize - .5;
float2 base = floor(texel) + .5;
float2 ts = frac(texel);
// can get everything in here in two 1d texture lookups
float4 kx = getK(ts.x);
float4 ky = getK(ts.y);
float2 x0 = lerpValues(kx.xy);
float2 x1 = lerpValues(kx.zw);
float2 y0 = lerpValues(ky.xy);
float2 y1 = lerpValues(ky.zw);
// end stuff to precalculate
// sample from map
float2 s00 = tex2D(map, invTexSize * (base + float2(x0.x, y0.x) + float2(-1,-1))).xy;
float2 s01 = tex2D(map, invTexSize * (base + float2(x0.x, y1.x) + float2(-1,1))).xy;
float2 s10 = tex2D(map, invTexSize * (base + float2(x1.x, y0.x) + float2(1,-1))).xy;
float2 s11 = tex2D(map, invTexSize * (base + float2(x1.x, y1.x) + float2(1,1))).xy;
float4 scales = float4(x0.y, x0.y, x1.y, x1.y) * float4(y0.y, y1.y, y0.y, y1.y);
return float2(dot(float4(s00.x, s01.x, s10.x, s11.x), scales),dot(float4(s00.y, s01.y, s10.y, s11.y), scales)) ;
}
float posterize(float c, float tiers, float bottomFilter, float topFilter)
{
c = saturate(saturate((c - bottomFilter))/(topFilter-bottomFilter));
c = c*tiers;
c = ceil(c);
c = c/tiers;
return c;
}
float ComputeAOTerm(sampler heightMap, in float2 heightMapUV, in float2 aoTapSpacing)
{
const float power = 0.9;
const float contrast = 0.18;
const int aoSamples = 10;
const float darkness = (4 * 8.0) / aoSamples;
const float step = (3.14159 * 2.0) / aoSamples;
const float startAngle = 40.0 / 57.3;
float spacing = (1.0 / 256.0) * contrast * aoTapSpacing.y;
float currentHeight = tex2D(heightMap, heightMapUV).x;
float2 sc = float2(0,0);
float occluded = 0;
for (int i = 0; i < aoSamples; i++)
{
float a = startAngle + step * i;
sincos(a, sc.x, sc.y);
float2 uv = float2(sc.x * spacing * (1+i%2), sc.y * spacing * (1+i%2));
float sample = tex2D(heightMap, heightMapUV + uv).x;
float o = saturate(sample - currentHeight);
occluded += o;
}
occluded = pow(occluded, power);
occluded *= darkness;
return saturate(occluded);
}
float3 ComputeAOColor(float term)
{
const float3 aoColorMin = float3(1.0, 1.0, 1.0);
const float3 aoColorMax = float3(0.405, 0.34, 0.32) * 0.1;
float3 finalAOColor = lerp(aoColorMin, aoColorMax, term);
return finalAOColor;
}
float3 ComputeAOColorForHeavyLayer(float term)
{
const float3 aoColorMin = float3(1.0, 1.0, 0.95) * 1.1;
const float3 aoColorMax = float3(1.0, 1.0, 1.0) * -1.15;
float3 finalAOColor = lerp(aoColorMin, aoColorMax, term*term);
return finalAOColor;
}
sampler forestNormalMap        : register(s0);  
sampler topDownTerrainNormals  : register(s1);
sampler contourMap             : register(s6);
sampler heightMap              : register(s2);  
// Contour map may or may not be a combined map of different contours. Regardless,
// the primary contour map is always the red channel.

// ---- fragment body (spliced into the generated main()) ----
float4 worldPos    = float4(In.texcoord<t2>.xyz, 1);
float waterLevel = terrainInfoPS.mReflectionParams.x;
float waterDepth = waterLevel - worldPos.z;  
float waterMask = waterDepth >= 0.0 ? 1.0 : 0.0;
topDownUV = In.texcoord<t0>.xy; 
float2 contourMapUV = In.texcoord<t0>.zw;
float2 heightMapUV = In.texcoord<t0>.xy;   
float2 aoTapSpacing = In.texcoord<t1>.zw;
float2 texSize = contourInfo.mTextureSize.xy;
float2 texelSize = contourInfo.mTextureSize.zw;
float tiers = contourInfo.mContourInfo[0].x;
float bottomFilter = contourInfo.mContourInfo[0].y;
float topFilter = contourInfo.mContourInfo[0].z;
float3 primaryContourColor = contourInfo.mMapColor[0].rgb;
float2 ecoMap = bicubic(contourMap, contourMapUV, texSize, texelSize);
// Coarse terrain normal
float4 normalMapSample = tex2D(topDownTerrainNormals, topDownUV);
float3 terrainNormal = normalMapSample.xyz * 2.0 - 1.0;
float3 specColor = float3(0.1, 0.1, 0.1);
