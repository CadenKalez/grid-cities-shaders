// Shader fragment  [PS slot 506]  readBloomPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008

// ---- declarations / helper functions ----
extern uniform sampler colorMap : register(s0);
extern uniform sampler bloom : register(s1);

// ---- fragment body (spliced into the generated main()) ----
float2 screenUV = In.texcoord<t0>.xy;
float3 texColor = tex2D(colorMap, screenUV).rgb;
float3 bloomColor = tex2D(bloom, screenUV).rgb;
