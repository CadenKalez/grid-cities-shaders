// Material shader: hejlToneMap
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
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform struct { float4 mGammaAndFog;float4 mFogInfo;float4 mWindInfo;} userGammaAndFog;
extern uniform sampler map : register(s0);

void main_pixel()
{
    // --- fragment: hejlToneMapPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 texColor = tex2D(map, In.texcoord<t0>.xy).rgb;
    // hejl vision:
    texColor *= sunSky.mSunColor.w;
    float3 x = max(float3(0, 0, 0), texColor-0.004);
    float3 outColor = (x*(6.2*x+.5))/(x*(6.2*x+1.7)+0.06);
    float gamma = userGammaAndFog.mGammaAndFog.x;
    // Results of Hejl tonemapping is in sRGB space so all we need to do is apply
    // the user requested ramp and post-monitor-gamma-correction, the final image
    // will be in the user requested gamma space.
    outColor = pow(outColor, make_float3(gamma));
    Current.color.rgba = float4(outColor,1);
}
