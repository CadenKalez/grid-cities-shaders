// Shader fragment  [PS slot 265]  vehicleSpecularHotSpotPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008

// ---- declarations / helper functions ----
float linearStep1( float start, float invRange, float value )
{
return saturate( ( value - start ) * invRange );
}

// ---- fragment body (spliced into the generated main()) ----
float lightToReflectMagnitude = length( reflectedView - sunSky.mSunDir.xyz );
float hotSpotIntensity        = linearStep1( 0.93f, 0.5f, 1.0f - lightToReflectMagnitude );
// Put in range 0-1
hotSpotIntensity = saturate( hotSpotIntensity * 44.0f );
// Raise to power
hotSpotIntensity = pow( hotSpotIntensity, 8.0f );
float3 hotSpotColour = sunSky.mSunColor.rgb * ( hotSpotIntensity * 9.0f ) * specStrength * shadowModulation;
finalColor += hotSpotColour;
