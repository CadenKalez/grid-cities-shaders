// Shader fragment  [PS slot 167]  terrainDeferredPS2Plane

// ---- uniform parameters ----
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mNormalParams; float4 mColor; } terrainInfoPS;   // reg-meta 028202820004000000000008
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- declarations / helper functions ----
uniform sampler forestNormalMap        : register(s0);  
uniform sampler topDownTerrainNormals  : register(s1);  
uniform sampler heightMap              : register(s2);  
uniform sampler controlMap             : register(s3);  
uniform samplerCUBE normalCubeMap      : register(s4);  
uniform sampler noiseMap               : register(s5);  
uniform sampler combinedEcoMaps        : register(s6);  
static const float kCreaseStrength = .3;
static const float kCreaseStart    = 0.8;
static const float kAmbient                = 0.0;
static const float kLightingColorScale     = 0.35;
static const float3 kAverageGrassColor = (
float3(143/255.0, 196/255.0, 70/255.0) +
float3(87/255.0, 124/255.0, 55/255.0)  +
float3(131/255.0, 174/255.0, 84/255.0) +
float3(105/255.0, 149/255.0, 55/255.0)
);
static const float3 kGrassColorScale = float3(0.3, 0.4, 0.0) * 0.25;
static const float3 kDryGroundColor         = float3(1.0, 0.8, 0.0) * 0.3;
static const float3 kMoistGroundColor       = kAverageGrassColor * kGrassColorScale;
static const float3 kPollutedGroundColor    = float3(1,1,1) * 0.25;
static const float3 kSnowGroundColor        = float3(1,1,1) * 1.0;
static const float kBladeGroundBlend        = 0.0;
static const float kBladeTextureBlend       = 0.3;
static const float kBladeFadeScalar         = 0.0015;
static const float kGroundBladeFadeScalar   = 0.0003;
static const float3 kGrassImposterVertexScale   = float3(1.0, 1.0, 0.7);
static const float kBlendWithTerrainNormal = 0.95;
static const float kBorderWidth             = 2.0;
static const float kColorNoiseUVScale       = 3.0;
static const float kCrinklyNoiseUVScale     =  4.0;
static const float kCrinklyNoiseDown        = -0.5;
static const float kCrinklyNoiseScale       =  0.75;
static const float kCrinklyNoiseUp          =  0.4;
static const float kPatchyNoiseUVScale     =  0.5;
static const float kPatchyNoiseDown        = -0.225;
static const float kPatchyNoiseScale       =  1.5;
static const float kPatchyNoiseUp          = -0.3;
static const float kTriPlanarCliffTiling = 180.0;
static const float kTriPlanarCliffTilingDetail = 40.0;
static const float kTriPlanarGroundTiling = 250.0;
static const float kTriPlanarGroundTilingDetail = 30.0;
static const float kTriPlanarGroundTilingDetailMinSpec = 80.0;
static const float kTriPlanarPollutionTiling = 100.0;
static const float kTriPlanarSnowTiling = 100.0;
static const float kTriPlanarBlendWeights = -0.15;
static const float kTriPlanarDistanceBlend = 1.0/9000;
static const float kTriPlanarCliffMinDist = -1;
static const float kTriPlanarCliffMaxDist = .1;
static const float kTriPlanarSoilMinDist  = -0.75;
static const float kTriPlanarSoilMaxDist  = -0.5;
static const float kTriPlanarGrassMinDist = -0.85;
static const float kTriPlanarGrassMaxDist = -0.5;
static const float kTriPlanarPollutionMinDist = -0.85;
static const float kTriPlanarPollutionMaxDist = -0.5;
static const float kTriPlanarSnowMinDist = -0.85;
static const float kTriPlanarSnowMaxDist = -0.5;
static const float kBeachGrassLine = 2.0;
static const float kBeachDrySand = 0.3;
static const float kBeachWetSand = -1.0;
static const float BEACH_NOISE_TILING = 0.4;
static const float WATER_NORMAL_MAP_TILING1 = 120.0;
static const float WATER_NORMAL_MAP_TILING2 = 28.0;
static const float WATER_NORMAL_MAP_BLEND1 = 0.8;
static const float WATER_NORMAL_MAP_BLEND2 = 1.0;
static const float WATER_COARSE_NORMAL_SPACING = 1.0/256.0;
static const float WATER_COARSE_HEIGHT_SCALE   = 0.0023;
static const float WATER_HEIGHT_MAP_TILING     = 40.0;
static const float WATER_HEIGHT_MAP_TILING_FOAM = 5.0;
static const float WATER_HEIGHT_MAP_SCALE      = 1.0;
static const float WATER_HEIGHT_MAP_BIAS       = -4.0;
static const float WATER_CHOPPY_MAP_TILING     = 5.0;
static const float WATER_CHOPPY_MAP_SCALE      = 2;
static const float FOAM_CHOPPY_MAP_SCALE       = 0.0;
static const float FOAM_TILING                 = 280.0;
static const float FOAM_SATURATION             = 7.75;
static const float FOAM_MAX_DEPTH              = 3.5;
static const float FOAM_DIFFUSE_EFFECT         = 0.7;
static const float FOAM_HEIGHT_TAP_COUNT       = 5;
static const float FOAM_HEIGHT_TAP_SPACING     = (1.0/256.0) * 0.075;
float4 getControlChannels(sampler controlMap, sampler noiseMap, in float2 controlMapUV, in float2 heightMapUV)
{
float4 controlChannels = tex2D(controlMap, controlMapUV).rgba;
float2 satResult = saturate(controlMapUV);
float useControlMap = satResult.x == controlMapUV.x ? 1 : 0;
useControlMap *= satResult.y == controlMapUV.y ? 1 : 0;
controlChannels.a *= useControlMap;
controlChannels.a = saturate(lerp(0.0, kBorderWidth, controlChannels.a));
float noise = tex2D(noiseMap, controlMapUV * kCrinklyNoiseUVScale).x;
noise += kCrinklyNoiseDown;
noise *= kCrinklyNoiseScale;
noise += kCrinklyNoiseUp;
controlChannels.a = saturate(controlChannels.a + noise);
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
return controlChannels;
}
float4 getControlChannelsMinSpec(sampler controlMap, sampler noiseMap, in float2 controlMapUV, in float2 heightMapUV)
{
float4 controlChannels = tex2D(controlMap, controlMapUV).rgba;
float2 satResult = saturate(controlMapUV);
float useControlMap = satResult.x == controlMapUV.x ? 1 : 0;
useControlMap *= satResult.y == controlMapUV.y ? 1 : 0;
controlChannels.a *= useControlMap;
controlChannels.a = saturate(lerp(0.0, kBorderWidth, controlChannels.a));
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
controlChannels.a *= controlChannels.a;
return controlChannels;
}
float getGrassAmount(sampler combinedEcoMaps, in float2 heightMapUV, in float3 terrainNormal, float controlAmount, inout float4 ecoMapsOut, sampler noiseMap, in float2 controlMapUV)
{
ecoMapsOut = tex2D(combinedEcoMaps, heightMapUV).rgba;
float grassAmount = ecoMapsOut.r * ecoMapsOut.b;
grassAmount = sqrt(grassAmount);
float patchy = tex2D(noiseMap, controlMapUV * kPatchyNoiseUVScale).x;
patchy += kPatchyNoiseDown;
patchy *= kPatchyNoiseScale;
patchy += kPatchyNoiseUp;
grassAmount = sign(grassAmount) * saturate(grassAmount + patchy);
float flatness = saturate(terrainNormal.z);
flatness *= flatness;
flatness *= flatness;
flatness *= flatness;
flatness *= flatness;
grassAmount *= flatness;
grassAmount = saturate(grassAmount);
grassAmount *= 1.0 - controlAmount;
return grassAmount;
}
float getGrassAmountMinSpec(sampler combinedEcoMaps, in float2 heightMapUV, in float3 terrainNormal, float controlAmount, inout float4 ecoMapsOut, sampler noiseMap, in float2 controlMapUV)
{
ecoMapsOut = tex2D(combinedEcoMaps, heightMapUV).rgba;
float grassAmount = ecoMapsOut.r * ecoMapsOut.b;
float patchy = tex2D(noiseMap, controlMapUV * kPatchyNoiseUVScale ).x;
patchy += kPatchyNoiseDown;
patchy *= kPatchyNoiseScale;
patchy += kPatchyNoiseUp;
grassAmount =  sign(grassAmount) * saturate(grassAmount + patchy);
grassAmount *= 1.0 - controlAmount;
return grassAmount;
}
float computeGrassAmount(sampler controlMap, sampler combinedEcoMaps, sampler noiseMap, in float3 terrainNormal, in float2 controlMapUV, in float2 heightMapUV, inout float4 ecoMapsOut)
{
float4 controlChannels = getControlChannels(controlMap, noiseMap, controlMapUV, heightMapUV);
return getGrassAmount(combinedEcoMaps, heightMapUV, terrainNormal, controlChannels.a, ecoMapsOut, noiseMap, controlMapUV);
}
float computeGrassAmountMinSpec(sampler controlMap, sampler combinedEcoMaps, sampler noiseMap, in float3 terrainNormal, in float2 controlMapUV, in float2 heightMapUV, inout float4 ecoMapsOut)
{
float4 controlChannels = getControlChannelsMinSpec(controlMap, noiseMap, controlMapUV, heightMapUV);
return getGrassAmountMinSpec(combinedEcoMaps, heightMapUV, terrainNormal, controlChannels.a, ecoMapsOut, noiseMap, controlMapUV);
}
float densityThreshold(in float4 pixelNormal, in float grassAmount, in float fade)
{
float bladeID = pixelNormal.a;
float mask = bladeID - 0.004;
float select = grassAmount * fade - bladeID;
return min(mask, select);
}
float3 computeGrassNormal(float3 terrainNormal, in float3 grassNormal)
{
grassNormal = lerp(grassNormal, terrainNormal, kBlendWithTerrainNormal);
grassNormal = normalize(grassNormal);
return grassNormal;
}
float3 computeBasicGroundColor(in float4 ecoMaps, float grassAmount)
{
float3 groundColor = lerp(kDryGroundColor, kMoistGroundColor, grassAmount);
groundColor = lerp(groundColor, kAverageGrassColor * kGrassColorScale, kBladeGroundBlend);
groundColor = lerp(groundColor, kPollutedGroundColor, ecoMaps.a);
return groundColor;
}
float3 testRayPlane(in float3 rayOrigin, in float3 rayDir, in float3 Pp, in float3 Pn, inout float tDist)
{
float Pd = -dot(Pp, Pn);
float Vd = dot(Pn, rayDir);
float V0 = -(dot(Pn, rayOrigin) + Pd);
tDist = V0 / Vd;
float3 rayHit = rayOrigin + (rayDir * tDist);
return rayHit;
}
float3 ComputeBeachValues(sampler noiseMap, float2 controlMapUV, float waterLevel, float worldZ)
{
float noise = tex2D(noiseMap, controlMapUV * BEACH_NOISE_TILING).x;
noise -= 0.25;
noise *= 2.75;
noise += 0.3;
float trees = worldZ - (waterLevel + kBeachGrassLine + noise);
float drySand = (waterLevel + kBeachDrySand + noise) - worldZ;
float wetSand = (waterLevel + kBeachWetSand + noise) - worldZ;
float3 res = float3(drySand, trees, wetSand);
return res;
}
float3 GetSnowAmount(in float worldPosZ, in float snowLevel)
{
float3 snow = float3(0,0,0);
snow.x = saturate((worldPosZ - snowLevel) / 80.0);
snow.y = snow.x * 0.65;
snow.z = snow.x;
return snow;
}
static const float kTreeDirtPatchScale  = 3.0f;
static const float kTreeShadowDarkening = 0.9f;
static const float kStartFadeDistance = 3000.0f;
static const float kEndFadeDistance   = 3750.0f;
static const float kNormalBias = 0.45f;
static const float kCliffCullingAngle = 0.5f;
static const float kTreeMinSize  = 0.3f;
static const float kTreeMaxSize  = 0.9f;
static const float kTreeSizeVary = 0.05f;
static const float kBeachTreeLine = 8.5f;
float GetFadeValue( in float3 worldPos, in float3 worldCameraPos )
{
float distanceToCam = length( worldPos - worldCameraPos );
float fadeValue     = saturate( ( distanceToCam - kStartFadeDistance ) / ( kEndFadeDistance - kStartFadeDistance ) );
return fadeValue;
}
float GetCameraDirFade( in float3 worldCameraDir )
{
const float3 upAxis = float3( 0.0f, 0.0f, 1.0f );
float fadeValue = saturate( dot( -worldCameraDir.xyz, upAxis ) );
return fadeValue;
}

// ---- fragment body (spliced into the generated main()) ----
{
float2 heightMapUV = In.texcoord<t0>.xy;   
float2 controlMapUV = In.texcoord<t0>.zw;  
float4 worldPos = float4(In.texcoord<t2>.xyz, 1);
float waterLevel = terrainInfoPS.mWaterInfo.x;
float snowLevel = terrainInfoPS.mWaterInfo.y;
float treeDirtPatchAmount = 1.0f;
float4 forestNormal = float4(0,0,0,0);
float forestAmount = 0.0f;
forestNormal = tex2D(forestNormalMap, heightMapUV).xyzw;
float forestAlpha = forestNormal.w;
forestNormal.xyz = forestNormal.xyz * 2.0 - 1.0;
forestNormal.xyz = normalize(lerp(forestNormal.xyz, -worldCameraDirection.xyz, kNormalBias));
forestAmount = GetFadeValue(worldPos.xyz, worldCameraPosition.xyz) * forestAlpha;
treeDirtPatchAmount = saturate((1.0 - forestAlpha) * kTreeDirtPatchScale);
float3 terrainNormal = tex2D(topDownTerrainNormals, heightMapUV).xyz * 2.0 - 1.0;  
float4 ecoMapValues;  
float grassAmount = computeGrassAmount(controlMap, combinedEcoMaps, noiseMap, terrainNormal, controlMapUV, heightMapUV, ecoMapValues);
float4 clipPosition1 = mul(float4(worldPos.xyz,1), worldToClip);
float currentDepth = clipPosition1.w * nearFar.w * 255.0;
Current.color.xyz = float3(floor(currentDepth) / 255.0, floor(frac(currentDepth)*255.0) / 255.0, frac(currentDepth*255.0));  
float increaseWithDistance = saturate(clipPosition1.w * kTriPlanarDistanceBlend);
float3 triplanarPos = worldPos.xyz + 16384;
float2 coords2D[8];
coords2D[0] = frac(triplanarPos.yz / kTriPlanarCliffTilingDetail) * 2.0 - 1.0;   
coords2D[1] = frac(triplanarPos.zx / kTriPlanarCliffTilingDetail) * 2.0 - 1.0;   
coords2D[2] = frac(triplanarPos.yz / kTriPlanarCliffTiling) * 2.0 - 1.0;         
coords2D[3] = frac(triplanarPos.zx / kTriPlanarCliffTiling) * 2.0 - 1.0;         
coords2D[4] = frac(triplanarPos.xy / kTriPlanarGroundTilingDetail) * 2.0 - 1.0;  
coords2D[5] = frac(triplanarPos.xy / kTriPlanarGroundTiling) * 2.0 - 1.0;        
coords2D[6] = frac(triplanarPos.xy / kTriPlanarPollutionTiling) * 2.0 - 1.0;     
coords2D[7] = frac(triplanarPos.xy / kTriPlanarSnowTiling) * 2.0 - 1.0;          
float3 beachValues = ComputeBeachValues(noiseMap, controlMapUV, waterLevel, worldPos.z);
float3 coords3D[12];
coords3D[0] = (float3(coords2D[0].x, coords2D[0].y, 1.0));  
coords3D[1] = (float3(coords2D[1].y, coords2D[1].x, 1.0));  
coords3D[2] = (float3(coords2D[2].x, coords2D[2].y, 1.0));  
coords3D[3] = (float3(coords2D[3].y, coords2D[3].x, 1.0));  
coords3D[4] = beachValues.x > 0 ? float3(coords2D[4].x, coords2D[4].y, -1.0) : float3(1.0, coords2D[4].x, coords2D[4].y);  
coords3D[5] = beachValues.x > 0 ? float3(coords2D[5].x, coords2D[5].y, -1.0) : float3(1.0, coords2D[5].x, coords2D[5].y);  
coords3D[6] = (float3(coords2D[4].x,  1.0, coords2D[4].y));  
coords3D[7] = (float3(coords2D[5].x,  1.0, coords2D[5].y));  
coords3D[8] = (float3(coords2D[4].x, -1.0, coords2D[4].y));  
coords3D[9] = (float3(coords2D[6].x, -1.0, coords2D[6].y));  
coords3D[10] = (float3(-1.0, coords2D[4].x, coords2D[4].y));  
coords3D[11] = (float3(-1.0, coords2D[7].x, coords2D[7].y));  
float3 cubeMapSamples[12];
cubeMapSamples[0] = texCUBE(normalCubeMap, coords3D[0]).xyz * 2.0 - 1.0;  
cubeMapSamples[1] = texCUBE(normalCubeMap, coords3D[1]).xyz * 2.0 - 1.0;  
cubeMapSamples[2] = texCUBE(normalCubeMap, coords3D[2]).xyz * 2.0 - 1.0;  
cubeMapSamples[3] = texCUBE(normalCubeMap, coords3D[3]).xyz * 2.0 - 1.0;  
cubeMapSamples[4] = texCUBE(normalCubeMap, coords3D[4]).xyz * 2.0 - 1.0;  
cubeMapSamples[5] = texCUBE(normalCubeMap, coords3D[5]).xyz * 2.0 - 1.0;  
cubeMapSamples[6] = texCUBE(normalCubeMap, coords3D[6]).xyz * 2.0 - 1.0;  
cubeMapSamples[7] = texCUBE(normalCubeMap, coords3D[7]).xyz * 2.0 - 1.0;  
cubeMapSamples[8] = texCUBE(normalCubeMap, coords3D[8]).xyz * 2.0 - 1.0;  
cubeMapSamples[9] = texCUBE(normalCubeMap, coords3D[9]).xyz * 2.0 - 1.0;  
cubeMapSamples[10] = texCUBE(normalCubeMap, coords3D[10]).xyz * 2.0 - 1.0;  
cubeMapSamples[11] = texCUBE(normalCubeMap, coords3D[11]).xyz * 2.0 - 1.0;  
static const float kNormalScale = 1.7;
cubeMapSamples[2] = normalize(cubeMapSamples[2] * float3(1,1,kNormalScale));
cubeMapSamples[3] = normalize(cubeMapSamples[3] * float3(1,1,kNormalScale));
cubeMapSamples[4] = normalize(cubeMapSamples[4] * float3(1,1,kNormalScale));
cubeMapSamples[5] = normalize(cubeMapSamples[5] * float3(1,1,kNormalScale));
cubeMapSamples[6] = normalize(cubeMapSamples[6] * float3(1,1,kNormalScale));
cubeMapSamples[7] = normalize(cubeMapSamples[7] * float3(1,1,kNormalScale));
cubeMapSamples[8] = normalize(cubeMapSamples[8] * float3(1,1,kNormalScale));
cubeMapSamples[9] = normalize(cubeMapSamples[9] * float3(1,1,kNormalScale));
cubeMapSamples[10] = normalize(cubeMapSamples[10] * float3(1,1,kNormalScale));
cubeMapSamples[11] = normalize(cubeMapSamples[11] * float3(1,1,kNormalScale));
terrainNormal.z *= (1 - kCreaseStrength);
if (terrainNormal.z > (1 - kCreaseStrength) * kCreaseStart)
terrainNormal.z += kCreaseStrength;
float3 tanZ = terrainNormal;
float3 tanX = float3(1,0,0);
float3 tanY = cross(tanZ, tanX);
tanX = cross(tanY, tanZ);
tanX = normalize(tanX);
tanY = normalize(tanY);
float3x3 mtx = float3x3(tanX, tanY, tanZ);
cubeMapSamples[0] = mul(cubeMapSamples[0], mtx);  
cubeMapSamples[1] = mul(cubeMapSamples[1], mtx);  
cubeMapSamples[2] = mul(cubeMapSamples[2], mtx);  
cubeMapSamples[3] = mul(cubeMapSamples[3], mtx);  
cubeMapSamples[4] = mul(cubeMapSamples[4], mtx);  
cubeMapSamples[5] = mul(cubeMapSamples[5], mtx);  
cubeMapSamples[6] = mul(cubeMapSamples[6], mtx);  
cubeMapSamples[7] = mul(cubeMapSamples[7], mtx);  
cubeMapSamples[8] = mul(cubeMapSamples[8], mtx);  
cubeMapSamples[9] = mul(cubeMapSamples[9], mtx);  
cubeMapSamples[10] = mul(cubeMapSamples[10], mtx);  
cubeMapSamples[11] = mul(cubeMapSamples[11], mtx);  
float cliffSmoothStep = smoothstep(kTriPlanarCliffMinDist, kTriPlanarCliffMaxDist, increaseWithDistance);
float soilSmoothStep  = smoothstep(kTriPlanarSoilMinDist,  kTriPlanarSoilMaxDist,  increaseWithDistance);
float grassSmoothStep = smoothstep(kTriPlanarGrassMinDist, kTriPlanarGrassMaxDist, increaseWithDistance);
float pollutionSmoothStep = smoothstep(kTriPlanarPollutionMinDist, kTriPlanarPollutionMaxDist, increaseWithDistance);
float snowSmoothStep = smoothstep(kTriPlanarSnowMinDist, kTriPlanarSnowMaxDist, increaseWithDistance);
float3 blends[6];
blends[0] = cubeMapSamples[2] + (cubeMapSamples[0] - cubeMapSamples[2]) * cliffSmoothStep;  
blends[1] = cubeMapSamples[3] + (cubeMapSamples[1] - cubeMapSamples[3]) * cliffSmoothStep;  
blends[2] = cubeMapSamples[5] + (cubeMapSamples[4] - cubeMapSamples[5]) * soilSmoothStep;   
blends[3] = cubeMapSamples[7] + (cubeMapSamples[6] - cubeMapSamples[7]) * grassSmoothStep;  
blends[4] = cubeMapSamples[9] + (cubeMapSamples[8] - cubeMapSamples[9]) * pollutionSmoothStep;  
blends[5] = cubeMapSamples[11] + (cubeMapSamples[10] - cubeMapSamples[11]) * snowSmoothStep;  
grassAmount *= (1.0 - saturate(-beachValues.y));  
float3 groundNormal = lerp(blends[2], blends[3], grassAmount * treeDirtPatchAmount);
float3 blendWeights = abs(float3(terrainNormal));
blendWeights = max(blendWeights + kTriPlanarBlendWeights, 0.0);
blendWeights /= (blendWeights.x + blendWeights.y + blendWeights.z);
float3 triplanarNormal =
blends[0].xyz * blendWeights.xxx +
blends[1].xyz * blendWeights.yyy +
groundNormal * blendWeights.zzz;
float pollutionAmount = ecoMapValues.w;
float3 snowAmount = GetSnowAmount(worldPos.z, snowLevel);  
triplanarNormal = lerp(triplanarNormal, blends[5], snowAmount.y);
triplanarNormal = lerp(triplanarNormal, blends[4], pollutionAmount);
triplanarNormal = lerp(triplanarNormal, forestNormal.xyz, forestAmount);
float gloss = 1.0f;
float specPow = 64.0 / 255.0;
Current.color.w = specPow;  
Current.color1 = float4(triplanarNormal * 0.5 + 0.5, gloss);
}
