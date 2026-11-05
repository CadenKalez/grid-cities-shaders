// Material shader: terrainDataViewBlendContoursShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mMisc; float4 mTessellation; float4 mMapping; float4 mMorph; float4x4 mMatrix; } terrainRegionInfoVS;
uniform float4 worldCameraPosition;
sampler HeightMapVS : register(s0);
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;
uniform float4 nearFar;

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000080044000000000000000100000001ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: unpackNormal   (cond 01022c0000000000000004000000000000000100000001ff)
    Current.normal.xyz = Current.normal.xyz * 1.0/127.0 - 1;
    // --- fragment: terrainRegionVS   (cond 0000000000000000000000000000000000000000000000ff)
    {
    float uvScale = terrainRegionInfoVS.mMisc.y;  
    float2 flatPos = Current.position.xy;
    float2 gridUV = flatPos.xy / uvScale;  
    float4 tessellation = terrainRegionInfoVS.mTessellation.xyzw;  
    gridUV *= -1;
    float4 morph = float4(0,0,0,0);
    morph.x = (gridUV.y > 0) && (abs(gridUV.y) > abs(gridUV.x)) ? tessellation.x : 0;  
    morph.y = (gridUV.y < 0) && (abs(gridUV.y) > abs(gridUV.x)) ? tessellation.y : 0;  
    morph.z = (gridUV.x > 0) && (abs(gridUV.x) > abs(gridUV.y)) ? tessellation.z : 0;  
    morph.w = (gridUV.x < 0) && (abs(gridUV.x) > abs(gridUV.y)) ? tessellation.w : 0;  
    float morphAmount = morph.x + morph.y + morph.z + morph.w;
    float2 morphStep = terrainRegionInfoVS.mMorph.xy;  
    morphStep *= Current.position.zw;  
    flatPos += morphStep * morphAmount;
    float2 heightMapUV = flatPos.xy / uvScale;
    heightMapUV += float2(0.5, 0.5);
    heightMapUV.xy *= terrainRegionInfoVS.mMapping.xy;
    heightMapUV.xy += terrainRegionInfoVS.mMapping.zw;
    float4 transformedPos = mul(terrainRegionInfoVS.mMatrix, float4(flatPos, 0, 1));
    flatPos.xy = transformedPos.xy;
    float height = tex2Dlod(HeightMapVS, float4(heightMapUV.x, heightMapUV.y, 0, 0)).x;  
    height *= 2048.0;  
    height -= 1024.0;  
    float2 toVertex2D = flatPos.xy - worldCameraPosition.xy;
    gridUV = Current.position.xy / uvScale;  
    gridUV += 0.5;  
    float2 vertexTangent = float2(0,0);
    vertexTangent.x = gridUV.x == 0.0 ?  1 : vertexTangent.x;
    vertexTangent.x = gridUV.x == 1.0 ? -1 : vertexTangent.x;
    vertexTangent.y = gridUV.y == 0.0 ?  1 : vertexTangent.y;
    vertexTangent.y = gridUV.y == 1.0 ? -1 : vertexTangent.y;
    float dp = dot(vertexTangent, toVertex2D);
    float performFix = -sign(dp);
    const float fixDistance = 5;  
    float fixAmount = smoothstep(3000, 4000, length(toVertex2D));  
    float heightDifference = height - worldCameraPosition.z;
    float3 toVertex3D = float3(toVertex2D.xy, heightDifference);
    toVertex3D = normalize(toVertex3D);
    toVertex2D = normalize(toVertex2D);
    float dp2 = dot(toVertex3D.xyz, float3(toVertex2D, 0));
    fixAmount *= step(0.97, dp2);  
    height += fixDistance * fixAmount * performFix;
    float3 worldPos = float3(flatPos.xy, height);
    float2 controMapUV = worldPos.xy / 2048.0 + 0.5;  
    Current.position = float4(worldPos, 1);
    Current.texcoord<t0> = float4(heightMapUV, controMapUV);
    Current.texcoord<t1> = float4(terrainRegionInfoVS.mMorph);  
    Current.texcoord<t2> = Current.position;
    }
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: outputDepthVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color = make_float4(clipPosition.w * nearFar.w * 255.0f);
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mNormalParams; float4 mColor; } terrainInfoPS;
uniform float4x4 worldToClip;
uniform float4 nearFar;
uniform float4 worldCameraPosition;
uniform float4 worldCameraDirection;
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

void main_pixel()
{
    // --- fragment: coordSetup   (cond 0000000000000000000000000000000000000000000000ff)
    float2 topDownUV = In.texcoord<t0>.xy;
    // --- fragment: outputDepthPS   (cond 0000000000000000000000000000000000000000000000ff)
    float outputDepth = In.color.x;
    Current.color.xyz = float3(floor(outputDepth) / 255.0, floor(frac(outputDepth)*255.0) / 255.0, frac(outputDepth*255.0));
    // --- fragment: terrainDataViewDeferredPS   (cond 0000000000000000000000000000000000000000000000ff)
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
}
