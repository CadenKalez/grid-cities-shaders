// Shader fragment  [PS slot 176]  terrainDataViewDeferredPS

// ---- uniform parameters ----
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mNormalParams; float4 mColor; } terrainInfoPS;   // reg-meta 028202820004000000000008
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- declarations / helper functions ----
sampler forestNormalMap        : register(s0);  
sampler topDownTerrainNormals  : register(s1);  
sampler heightMap              : register(s2);  
sampler controlMap             : register(s3);  
sampler grassNormalMap         : register(s4);  
sampler noiseMap               : register(s5);  
sampler combinedEcoMaps        : register(s6);  
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
float4 worldPos = float4(In.texcoord<t2>.xyz, 1);
//clip(abs(worldPos.x) > 1024 || abs(worldPos.y) > 1024 ? -1 : 0);
float4 forestNormal = tex2D(forestNormalMap, heightMapUV).xyzw;
float forestAlpha = forestNormal.w;
forestNormal.xyz = forestNormal.xyz * 2.0 - 1.0;
forestNormal.xyz = normalize(lerp(forestNormal.xyz, -worldCameraDirection.xyz, kNormalBias));
float forestAmount = GetFadeValue(worldPos.xyz, worldCameraPosition.xyz) * forestAlpha;
float3 terrainNormal = tex2D(topDownTerrainNormals, topDownUV).xyz * 2.0 - 1.0;  
terrainNormal = lerp(terrainNormal, forestNormal.xyz, forestAmount);
float gloss = 1.0f;
float specPow = 64.0 / 255.0;
Current.color.w = specPow;  
Current.color1 = float4(terrainNormal.xyz * 0.5 + 0.5, gloss);
}
