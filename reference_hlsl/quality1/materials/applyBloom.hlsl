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
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
extern uniform sampler colorMap : register(s0);
extern uniform sampler bloom : register(s1);
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;

void main_pixel()
{
    // --- fragment: readBloomPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = In.texcoord<t0>.xy;
    float3 texColor = tex2D(colorMap, screenUV).rgb;
    float3 bloomColor = tex2D(bloom, screenUV).rgb;
    // --- fragment: applyBloomPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 outColor = clamp(texColor,0.0,sunSky.mZenith.w)+bloomColor*bloomColor;
    Current.color.rgba = float4(outColor,1);
}
