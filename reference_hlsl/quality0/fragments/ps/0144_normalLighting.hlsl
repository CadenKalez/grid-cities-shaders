// Shader fragment  [PS slot 144]  normalLighting

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008

// ---- fragment body (spliced into the generated main()) ----
const float MIN_DIFFUSE = 0.30;
color.rgb = pow(color.rgb, float3(2.2, 2.2, 2.2));
float diffuse = saturate((dot(sunSky.mSunDir.xyz, In.texcoord0.xyz) + 1)/2.0);
diffuse = MIN_DIFFUSE + (1 - MIN_DIFFUSE) * diffuse;
color *= diffuse;
color.a = 1.0;
