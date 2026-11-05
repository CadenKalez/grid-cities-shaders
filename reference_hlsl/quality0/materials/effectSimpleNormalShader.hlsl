// Material shader: effectSimpleNormalShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 customParams[2];
uniform float4x4 modelToClip;

void main_vertex()
{
    // --- fragment: effectSimpleSetupMinSpecVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 position  = modelPosition.xyz;
    float4 color = In.color;
    float2 tileSize = In.texcoord0.xy;
    float age = In.weights.x;
    float frameDelta = In.weights.y;
    float2 tiles = In.color1.xy * 255;
    int corner = int(In.weights.w * 255);
    int cx = corner % 2;
    int cy = corner / 2;
    tiles += float2(cx, 1 - cy);
    float2 uvTile1 = tileSize * tiles.xy;
    float2 uvTile2 = uvTile1;
    // --- fragment: effectSimpleCrushVF   (cond 0000000000000000000000000000000000000000000000ff)
    float blackPoint;
    float midPoint;
    float fadeRate = customParams[0].w;
    blackPoint = 0.0f;
    if ( fadeRate > 1.f )
    {
    blackPoint = saturate( 1-age * (fadeRate - 1) );
    }
    else
    {
    blackPoint = saturate( age * fadeRate );
    }
    midPoint = ( 1.0 + blackPoint ) * 0.5;
    // --- fragment: effectSimpleOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position            = mul( float4( modelPosition.xyz, 1 ), modelToClip ); 
    Current.color               = color;
    Current.texcoord<t0>        = float4( uvTile1.xy, uvTile2.xy );
    Current.texcoord<t1>        = float4( frameDelta, 0, blackPoint, midPoint );
    Current.texcoord<t2>        = Current.position;
}

//==============================================================================
// PIXEL SHADER  (6 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler map : register(s0);
uniform float4x3 cameraToWorld;
uniform float4 gameInfo;
uniform float4 shCoeffs[4];
uniform float4 worldCameraDirection;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
extern uniform sampler nmmap : register(s1);
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
uniform float4 customParams[2];
uniform float4 customParams[2];

void main_pixel()
{
    // --- fragment: effectSimpleInputPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4  color           =  In.color;
    float2  uvTile1         =  In.texcoord0.xy;
    float2  uvTile2         =  In.texcoord0.zw;
    float   frameDelta      =  In.texcoord1.x;
    float   blackPoint      =  In.texcoord1.z;
    float   midPoint        =  In.texcoord1.w;
    float4  particleClipPos  =  In.texcoord2;
    // --- fragment: effectSimpleSampleDiffuseMinSpecPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 diffuse     = tex2D(map, uvTile1);
    // --- fragment: effectSimpleNormalMapPFMinSpec   (cond 0000000000000000000000000000000000000000000000ff)
    // compute normal map
    float4 texNMap = tex2D(nmmap, float2(uvTile1.x, uvTile1.y));
    float3 normal = 2 * texNMap.rgb - 1;
    normal.z = -normal.z;   // flip z to point towards camera
    normal = mul(float4(normal, 0), cameraToWorld);
    float3 shDiff, shSpec;
    SHDiffSpec4(normal, shDiff, shSpec, false);
    float sunMod = saturate(dot(sunSky.mSunDir.xyz, normal));
    shDiff += sunMod * sunSky.mSunColor.rgb;
    diffuse.rgb *= lerp(shDiff, shSpec, texNMap.a);
    // --- fragment: effectSimpleCrushPF   (cond 0000000000000000000000000000000000000000000000ff)
    float crushAlpha = customParams[0].x;
    float crushRGB   = customParams[0].y;
    if ( crushAlpha != 0 )
    {
    float4 crush = float4(0, 0, 0, 0);
    if ( diffuse.a < midPoint )
    crush += midPoint * ( diffuse - blackPoint ) / ( midPoint - blackPoint + 0.0001 );
    else
    crush += diffuse;
    diffuse.rgb     = lerp(diffuse.rgb, crush.rgb, crushRGB);
    diffuse.a       = lerp(diffuse.a, crush.a, crushAlpha);
    }
    // --- fragment: effectSimpleMultiplyAndBlendMinSpecPF   (cond 0000000000000000000000000000000000000000000000ff)
    float colorMultiply = customParams[0].z;
    diffuse *= color;
    diffuse.rgb *= colorMultiply;
    // --- fragment: effectSimpleOutputPF   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.a = diffuse.a;
    Current.color.rgb = diffuse.rgb;
}
