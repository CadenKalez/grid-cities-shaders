// Shader fragment  [PS slot 508]  applyBloomPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008

// ---- fragment body (spliced into the generated main()) ----
float3 outColor = clamp(texColor,0.0,sunSky.mZenith.w)+bloomColor*bloomColor;
Current.color.rgba = float4(outColor,1);
