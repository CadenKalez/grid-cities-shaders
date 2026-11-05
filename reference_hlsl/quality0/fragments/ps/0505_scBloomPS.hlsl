// Shader fragment  [PS slot 505]  scBloomPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float3 texColor = tex2D(map, In.texcoord<t0>.xy).rgb;
float3 outColor = sqrt(max(texColor-sunSky.mZenith.w,0.0));
Current.color.rgba = float4(outColor,1);
