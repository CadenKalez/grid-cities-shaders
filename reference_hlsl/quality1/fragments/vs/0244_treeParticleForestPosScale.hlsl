// Shader fragment  [VS slot 244]  treeParticleForestPosScale

// ---- uniform parameters ----
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform struct { float4 mWaterLevel; float4 mTransform; float4 mMapping; } terrainForestInfoVS;   // reg-meta 029802980003000000000008

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
sampler HeightMapVS : register(s0);
sampler EcoMapVS    : register(s1);
sampler NormalMapVS : register(s2);

// ---- fragment body (spliced into the generated main()) ----
float2 cornerData = In.texcoord0.xy;
float3 modelData = In.normal.xyz;
float3 position = modelPosition.xyz;
float sampleIndex = In.color.a;
// The incoming quad positions are in the 0.0f -> 1.0f range.
float2 mapUV = position.xy * terrainForestInfoVS.mMapping.xy + terrainForestInfoVS.mMapping.zw;
// Sample height map and then remap 0.0f -> 1.0f value into the
// -1024.0f -> 1024.0f range.
float height;
height = tex2Dlod( HeightMapVS, float4( mapUV, 0.0f, 0.0f ) ).x;
height *= 2048.0f;
height -= 1024.0f;
// Sample the forest eco map and calc the size for the density culling check.
float density = tex2Dlod( EcoMapVS, float4( mapUV, 0.0f, 0.0f ) ).y;
float size    = density - sampleIndex;
// Sample the normal map and then calculate the angle for the cliff culling
// check.
float3 normal;
normal = tex2Dlod( NormalMapVS, float4( mapUV, 0.0f, 0.0f ) ).xyz;
normal = normal * 2.0f - 1.0f;
float3 flattenedNormal = normalize( float3( normal.xy, 0.0f ) );
float  angle           = abs( dot( normal, flattenedNormal ) );
// Calculate sea level for sea level check. A combination of a shader constant
// offsetted by the beach level.
float seaLevel = terrainForestInfoVS.mWaterLevel.x + kBeachTreeLine;
// The result of drawQuad determines if this tree quad is visible or not. If the
// result is 1, it means it is visible. 0 means hide the quad. Currently there are
// 3 checks that determine if the quad is hidden:
//  1) If it fails the density map check.
//  2) It is below sea level (plus beach line).
//  3) if it fails the cliff culling check.
// TODO: Possbly consider using a dynamic branch to skip the rest of the shader
//       if it's hidden to save some cost. But would it actually save anything?!
//       I say that as I can't really find solid info on whether they hurt perf
//       or not.
float drawQuad;
drawQuad = ( size <= 0.0f ) ? 0.0f : 1.0f;
drawQuad = ( angle >= kCliffCullingAngle ) ? 0.0f : drawQuad;
drawQuad = ( height < seaLevel ) ? 0.0f : drawQuad;
position.xy -= terrainForestInfoVS.mTransform.xy;
position = mul( float4( position, 1.0f ), modelToWorld );
position.z = height;
// Calculate the scale. modelData.x holds the random value for size variation.
float random = frac( modelData.x );
float scale  = lerp( kTreeMinSize, kTreeMaxSize, size ) + random * kTreeSizeVary;
