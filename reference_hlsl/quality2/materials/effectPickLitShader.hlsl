// Material shader: effectPickLitShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (10 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 worldCameraPosition;
uniform float4 worldCameraDirection;
uniform float4 gameInfo;
uniform float4 customParams[2];
uniform float4 shCoeffs[4];
uniform float4 worldCameraDirection;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
const static float kSH_A1 = 2.0 / 3.0;
const static float kSH_A2 = 1.0 / 4.0;
const static float kSH_A3 = 0;
const static float kSH_A4 = -1.0 / 24.0;
const static float kDefaultGloss = 0.00;
const static float kGlossyMax    = 1.0; // threshold at which glossy maxes out
const static float kCelOutlineThreshold        = 0.25;
const static float kCelOutlineThresholdRange   = 0.075;
const static float kCelStrength                = 0.3;
const static float kSpecExponentMaxValue = 60.0;
const static bool kSaveInstructions = false;
void SHDiffSpec4
(
float3      normal,
out float3  shColorDiff,
out float3  shColorSpec,
bool        translucency
)
{
float3 shColor;
float3 x0 = normal;
shColorDiff = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
float3 reflectV;
if (translucency)
reflectV = -normal;
else
reflectV = reflect(worldCameraDirection.xyz, normal);
x0 = reflectV;
shColorSpec = shCoeffs[0].xyz;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColorSpec += shColor;
}
uniform float4 shCoeffs[4];
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[4];
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: effectTransSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = Current.color1.rg;
    float scale = In.normal.w;
    {
    Current.texcoord<t0> = Current.color1;
    }
    // --- fragment: effectSetupVF   (cond 0000000000000000000000000000000000000000000000ff)
    float age = modelPosition.w;
    float4 color = In.color;
    float3 cameraPos = worldCameraPosition.xyz;
    float3 toCamera = cameraPos - modelPosition.xyz;
    float cameraDist = length( toCamera );
    float3 toCamNormal = toCamera / cameraDist;
    // --- fragment: effectCameraFaceVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 quadPos;
    {
    float3 up = normalize( In.normal.xyz );
    float3 tangent  = cross( worldCameraDirection.xyz, up );
    tangent = normalize( tangent );
    up = normalize( cross( tangent, worldCameraDirection.xyz ) );
    quadPos = modelPosition.xyz;
    quadPos += tangent * scale * (uv.x - 0.5);
    quadPos += up * scale * (0.5 - uv.y);
    }
    // --- fragment: effectPickTilesVF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 tileUV;
    {
    float id = Current.texcoord<t0>.w;
    float stripLength = customParams[0].y;
    float t = id * 255;
    float2 tile = float2( t, uv.y );
    tile /= stripLength;
    tile.x = frac( tile.x );
    tile.x += tile.y;
    tileUV = tile.xy;
    }
    // --- fragment: effectQuadNormal   (cond 0000000000000000000000000000000000000000000000ff)
    float3 normal = normalize(-0.125 * worldCameraDirection.xyz + quadPos - modelPosition.xyz); // normalize( -0.2 * In.normal.xyz + quadPos - modelPosition.xyz );
    // --- fragment: effectSCLighting   (cond 01028b0000000000000000000000000000000100000001ff)
    float3 shDiff, shSpec;
    SHDiffSpec4(normal, shDiff, shSpec, false); // normal is facing camera
    float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
    shDiff += sunMod * sunSky.mSunColor.rgb * 0.2;
    color.rgb *= shDiff;
    // --- fragment: effectSHLighting   (cond 0102190000000000000000000000000000000100000001ff)
    {
    const static float kSH_A1 = 2.0 / 3.0;
    float3 x0 = normal;
    float3 shColorDiff = shCoeffs[0];
    float3 shColor;
    shColor  = shCoeffs[1].xyz * x0.y;
    shColor += shCoeffs[2].xyz * x0.z;
    shColor += shCoeffs[3].xyz * x0.x;
    shColor *= kSH_A1;
    shColorDiff += shColor;
    color.rgb *= shColorDiff;
    }
    // --- fragment: effectDirLighting   (cond 0000000000000000000000000000000000000100000001ff)
    {
    const float ambient = 0.5;
    float LdotN = saturate( dot( normal, dirLightsWorld[0].mDir.xyz ) );
    color = lerp( color * dirLightsWorld[0].mColor * LdotN, color, ambient );
    }
    // --- fragment: effectToClipVF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 clipPos;
    {
    clipPos = mul( float4( quadPos, 1 ), modelToClip );
    }
    // --- fragment: effectOutputPickVF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position            = clipPos;
    Current.color               = color;
    Current.texcoord<t0>.xy     = float2( uv.x, tileUV.x );
    Current.texcoord<t0>.zw     = 0.0;
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler tileMap : register(s0);
uniform float4 customParams[1];

void main_pixel()
{
    // --- fragment: effectInputPickPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4  color           = In.color;
    float2  tileUV          = In.texcoord0.xy;
    // --- fragment: effectSamplePickTilePS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 tileTex      = tex2D( tileMap, tileUV );
    float4 diffuse      = tileTex * color;
    // --- fragment: effectPostMultiply   (cond 0000000000000000000000000000000000000000000000ff)
    diffuse.rgb *= customParams[0].z;
    // --- fragment: effectPS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb   = diffuse.rgb;
    Current.color.a		= diffuse.a;
}
