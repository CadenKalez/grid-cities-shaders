// Material shader: regionCityBuildingsImpostor
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (7 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 unitImpostorInstances[8];
uniform float4x3 modelToWorld;
uniform float4 customClipPlane;
uniform float4x3 worldToCamera;
uniform struct { float4 projScale; float4 projOffset; float4 viewScale; float4 viewOffset; float4x3 cameraTransform;float4 cameraAlignedProjOffset; } unitImpostorProjs;
static const int2  kPaletteSize = int2(256, 8);
static const float2 kPaletteInvSize = 1.0 / kPaletteSize;
// Convert from byte-represented color (0-1) to U value within texture
float BuildingPaletteVS(float palU)
{
// move to corner of 2x2 block
palU = palU * ((kPaletteSize.x - 1) * kPaletteInvSize.x);
return palU;
}
float BuildingPaletteVariationVS(int buildingType)
{
return buildingType * kPaletteInvSize.y;
}

void main_vertex()
{
    // --- fragment: unpackNormalTangent   (cond 01022c0000000000000000000000000000000000000000ff)
    Current.normal.xyz  = Current.normal.xyz  * 1.0/127.0 - 1;
    Current.tangent.xyz = Current.tangent.xyz * 1.0/127.0 - 1;
    // --- fragment: regionCityBuildingsImpostorWorldSpaceInstancedVS   (cond 0102ca0000000000000000000000000000000100000001ff)
    float3 worldPos = mul( float4( Current.position.xyz, 1.0f ), unitImpostorInstances[ In.binormal.x ] );
    // Output normal and tangent
    float3 outputNormal  = mul( float4( Current.normal.xyz, 0.0f ), unitImpostorInstances[ In.binormal.x ] );
    float3 outputTangent = mul( float4( Current.tangent.xyz, 0.0f ), unitImpostorInstances[ In.binormal.x ] );
    float poweredState = In.binormal.y;
    // --- fragment: regionCityBuildingsImpostorWorldSpaceVS   (cond 0000000000000000000000000000000000000100000001ff)
    float3 worldPos = mul( float4( Current.position.xyz, 1.0f ), modelToWorld );
    // Output normal and tangent
    float3 outputNormal  = mul( float4( Current.normal.xyz, 0.0f ), modelToWorld );
    float3 outputTangent = mul( float4( Current.tangent.xyz, 0.0f ), modelToWorld );
    float poweredState = customClipPlane.w;
    // --- fragment: regionCityBuildingsImpostorClipSpaceVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position.xyz = mul( float4( worldPos, 0.0f ), unitImpostorProjs.cameraTransform );
    float3 cameraAlignedProjScale  = unitImpostorProjs.cameraTransform[3];
    float3 cameraAlignedProjOffset = unitImpostorProjs.cameraAlignedProjOffset.xyz;
    float3 cameraSpacePosition = mul( float4( worldPos, 0.0f ), worldToCamera );
    cameraSpacePosition *= cameraAlignedProjScale;
    cameraSpacePosition += cameraAlignedProjOffset;
    // orthographic projection into bounding box space
    Current.position.xyz *= unitImpostorProjs.projScale.xyz;
    Current.position.xyz += unitImpostorProjs.projOffset.xyz;
    // send position to pixel shader for clipping by texture boundary
    float3 clipPosition = Current.position.xyz;
    // move into texture atlas
    Current.position.xyz *= unitImpostorProjs.viewScale.xyz;
    Current.position.xyz += unitImpostorProjs.viewOffset.xyz;
    float interiorLightTime = unitImpostorProjs.viewOffset.w;
    // --- fragment: regionCityBuildingsSetupVS   (cond 0000000000000000000000000000000000000000000000ff)
    // unpack rest of data from color
    float palU  = BuildingPaletteVS( In.color.r );
    float palU2 = BuildingPaletteVS( In.color.g );
    // unpack other texture coords
    float2 tileSize            = In.texcoord1.xy;
    float2 tileOffset          = In.texcoord1.zw;
    float2 tileSize2           = In.texcoord2.xy;
    float2 tileOffset2         = In.texcoord2.zw;
    float2 tilePadding         = In.texcoord3.xy;
    float2 interiorRoomInvSize = In.texcoord3.zw;
    float2 uv  = In.texcoord0.xy / abs( tileSize );
    float2 uv2 = In.texcoord0.zw / abs( tileSize2 );
    uv2 += ( tilePadding * 0.5f );
    uv2 /= ( 1.0f + tilePadding );
    // --- fragment: regionCityBuildingsPackVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = float4( uv, uv2 );
    Current.texcoord<t1> = float4( tileSize, tileOffset );
    Current.texcoord<t2> = float4( tileSize2, tileOffset2 );
    Current.texcoord<t3> = float4( tilePadding, palU, palU2 );
    Current.texcoord<t4> = float4( clipPosition.xyz, cameraSpacePosition.z );
    Current.texcoord<t5> = float4( interiorRoomInvSize, interiorLightTime, poweredState );
    // --- fragment: regionCityBuildingsImpostorPackVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = float4( outputNormal, 0.0f );
    Current.texcoord<t1> = float4( outputTangent, 0.0f );
}

//==============================================================================
// PIXEL SHADER  (7 fragments; each may be conditionally enabled)
//==============================================================================
sampler2D tintMapSampler        : register(s0);
sampler2D normalMapSampler      : register(s1);
sampler2D shaderMapSampler      : register(s2);
sampler2D tintPaletteSampler    : register(s3);
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
float FastNoise(float3 seed)
{
seed *= float3(78.233, 12.9898, 43758.5453);
seed += float3(0.819 * 78.233, 0.819 * 12.9898, 0.819 * 43758.5453);
float random = frac(seed.z * frac(seed.x * frac(seed.y)));
return random;
}
static const int    kNumPaletteEntries    = 256;
static const float  kInvNumPaletteEntries = 1.0f / kNumPaletteEntries;
static const float3 kZero3                = float3( 0.0f, 0.0f, 0.0f );
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}
static const bool kPerPixelDepth = false;
float4 ImpostorUnpackNormalDepth(float4 normalMapSample)
{
return float4(normalMapSample.xyz * 2 - 1, 0);
}
float3 ImpostorPackNormalDepth(float3 normal, float pixelDepth)
{
return float3(normal * 0.5 + 0.5);
}

void main_pixel()
{
    // --- fragment: regionCityBuildingsSamplersPS   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: regionCityBuildingsUnpackPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv                  = In.texcoord<t0>.xy;
    float2 uv2                 = In.texcoord<t0>.zw;
    float4 regionXform         = In.texcoord<t1>;
    float4 regionXform2        = In.texcoord<t2>;
    float2 tilePadding         = In.texcoord<t3>.xy;
    float  palU                = In.texcoord<t3>.z;
    float  palU2               = In.texcoord<t3>.w;
    float4 position            = In.texcoord<t4>.xyzw;
    float2 interiorRoomInvSize = In.texcoord<t5>.xy;
    float  interiorLightTime   = In.texcoord<t5>.z;
    float  poweredState        = In.texcoord<t5>.w;
    // --- fragment: regionCityBuildingsImpostorUnpackPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 worldNormal  = In.texcoord<t0>.xyz;
    float3 worldTangent = In.texcoord<t1>.xyz;
    // --- fragment: regionCityBuildingsImpostorClipPS   (cond 0000000000000000000000000000000000000000000000ff)
    // scissor window
    float4 clipPosition = position; // pre-atlas
    clip( float4( 1.0f + clipPosition.xy, 1.0f - clipPosition.xy ) );
    // --- fragment: regionCityBuildingsClipAndNoReliefMapPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv_ddx1 = ddx( uv * regionXform.xy );
    float2 uv_ddy1 = ddy( uv * regionXform.xy );
    float2 uv_ddx2 = ddx( uv2 * regionXform2.xy );
    float2 uv_ddy2 = ddy( uv2 * regionXform2.xy );
    float2 baseUv = frac( uv ) * regionXform.xy + regionXform.zw;
    float4 baseTintValues = tex2Dgrad( tintMapSampler, baseUv, uv_ddx1, uv_ddy1 );
    clip( baseTintValues.a - 0.5f );
    // handle padding and tiling
    float2 relief_tc;
    relief_tc = frac( uv2 );
    relief_tc = relief_tc * ( 1.0f + tilePadding ) - ( tilePadding * 0.5f );
    float4 tcBoundary = float4( 0.0f - relief_tc.xy, relief_tc.xy - 1.0f );
    float outsideTile = dot( saturate( tcBoundary ), 1.0f );  // we really just care about this being > 0, the magnitude is irrelevant
    relief_tc = relief_tc * regionXform2.xy + regionXform2.zw;
    // --- fragment: regionCityBuildingsBaseColorPS   (cond 0000000000000000000000000000000000000000000000ff)
    // sample textures
    float4 facadeTintValues = tex2Dgrad( tintMapSampler,    relief_tc, uv_ddx2, uv_ddy2 );
    float4 shaderMapBase    = tex2Dgrad( shaderMapSampler,  baseUv,    uv_ddx1, uv_ddy1 );
    float4 shaderMapTop     = tex2Dgrad( shaderMapSampler,  relief_tc, uv_ddx2, uv_ddy2 );
    facadeTintValues.a = ( outsideTile > 0 ) ? 0 : facadeTintValues.a;
    float4 shaderMapSampled = lerp( shaderMapBase, shaderMapTop, facadeTintValues.a );
    // TODO: actually fix up color variations. Pretty sure we'll need it as some
    //       point.
    // tint
    float4 tintBase;
    float4 specBase;
    BuildingPaletteSample( palU, 0.0f, float4( baseTintValues.rgb, 0.0f ), tintBase, specBase );
    float4 tintTop;
    float4 specTop;
    BuildingPaletteSample( palU2, 0.0f, float4( facadeTintValues.rgb, 0.0f ), tintTop, specTop );
    float4 tintResult = lerp( tintBase, tintTop, facadeTintValues.a );
    float2 interiorUv = uv * regionXform.xy * interiorRoomInvSize;
    int2 interiorElem = int2( floor( interiorUv ) );
    float random      = FastNoise( float3( interiorElem, 0.213425435f ) );
    float interior         = shaderMapSampled.a > 0.8f ? 0.0f : 1.0f;
    float interiorLighting = random > interiorLightTime ? interior : 0.0f;
    float3 finalColor = lerp( tintResult.rgb, kZero3, interior );
    // output
    Current.color = float4( finalColor, 1.0f );
    // --- fragment: regionCityBuildingsImpostorPackNormalDepthPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 normalMapBase = tex2Dgrad( normalMapSampler, baseUv,    uv_ddx1, uv_ddy1 );
    float4 normalMapTop  = tex2Dgrad( normalMapSampler, relief_tc, uv_ddx2, uv_ddy2 );
    // Is normal lerp good enough?  Should renormalize?
    float4 normalMapSampled = lerp( normalMapBase, normalMapTop, facadeTintValues.a );
    // unpack
    float3 normalMap = normalMapSampled.rgb;
    float3 nmapNormal = normalMap.rgb * 2 - 0.9985;
    float3 bumpNormal = ApplyNormalMap( worldNormal, worldTangent, nmapNormal );
    float3 normalOutput = ImpostorPackNormalDepth( bumpNormal, clipPosition.w );
    Current.color1.rgba = float4( normalOutput, interiorLighting * poweredState );
}
