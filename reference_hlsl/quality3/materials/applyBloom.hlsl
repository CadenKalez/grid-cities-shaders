// Material shader: applyBloom
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
extern uniform sampler colorMap : register(s0);
extern uniform sampler bloom : register(s1);
extern uniform sampler bloomSampler : register(s1);
float4 postLensFlarePS (float2 in_vTexCoord, int NumSamples, float4 vTint, float fTexScale, float fBlurScale, float fThreshold)
{
//Flip Screen so flare appears opposite bloom source
float2 vMirrorCoord = float2(1.0f, 1.0f) - in_vTexCoord;
float2 vNormalizedCoord = vMirrorCoord * 2.0f - 1.0f;
vNormalizedCoord *= fTexScale;
float2 screenSize = float2(1680,1050);
float2 vTowardCenter = normalize(-vNormalizedCoord);
float2 fBlurDist = fBlurScale * NumSamples;
float2 vStartPoint = vNormalizedCoord + ((vTowardCenter / screenSize) * fBlurDist);
float2 vStep = -(vTowardCenter / screenSize) * 2 * fBlurDist;
float4 vSum = 0;
float2 vSamplePos = vStartPoint;
float2 vSampleTexCoord = vSamplePos * 0.5f + 0.5f;
for (int i = 0; i < NumSamples; i++)
{
if (vSampleTexCoord.x >= 0 && vSampleTexCoord.x <= 1.0f && vSampleTexCoord.y >=0 && vSampleTexCoord.y <= 1.0f)
{
float4 vSample = tex2D(bloom, vSampleTexCoord);
vSum +=  max(0, vSample - fThreshold) * vTint;
}
vSamplePos += vStep;
vSampleTexCoord = vSamplePos * 0.5f + 0.5f;
}
return vSum / NumSamples;
}
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;

void main_pixel()
{
    // --- fragment: readBloomPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = In.texcoord<t0>.xy;
    float3 texColor = tex2D(colorMap, screenUV).rgb;
    float3 bloomColor = tex2D(bloom, screenUV).rgb;
    // --- fragment: lensBloomPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 tint = float4(0.7f, 0.3f, 0.8f, 1.0f);
    int flareSamples = 12;
    float flareOffset = 0.25f;
    float flareBlurScale = 0.5f;
    float flareThreshold = 2.25f;
    float flareIntensity = 0.25f;
    bloomColor += postLensFlarePS(screenUV, flareSamples, tint, flareOffset, flareBlurScale, flareThreshold).rgb  * flareIntensity;
    // --- fragment: applyBloomPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 outColor = clamp(texColor,0.0,sunSky.mZenith.w)+bloomColor*bloomColor;
    Current.color.rgba = float4(outColor,1);
}
