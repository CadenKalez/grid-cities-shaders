// Shader fragment  [PS slot 178]  terrainDataViewModifyTerrainNormalPS

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- declarations / helper functions ----
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
float2 forestMapOffset = normalize(sunSky.mSunDir.xy) * 0.0025;
float treeShadowMask = tex2D(forestNormalMap, heightMapUV + forestMapOffset).a;
float4 forestNormal = tex2D(forestNormalMap, heightMapUV).xyzw;
float forestAlpha = forestNormal.w;
forestNormal.xyz = forestNormal.xyz * 2.0 - 1.0;
forestNormal.xyz = normalize(lerp(forestNormal.xyz, -worldCameraDirection.xyz, kNormalBias));
float forestAmount = GetFadeValue(worldPos.xyz, worldCameraPosition.xyz) * forestAlpha;
terrainNormal = lerp(terrainNormal, forestNormal.xyz, forestAmount);
