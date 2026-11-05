// Shader fragment  [PS slot 138]  dataViewLightingMapPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008

// ---- declarations / helper functions ----
extern uniform sampler lightScalarSampler : register(s13);
void DataViewLighting
(
float3 normal,
float2 screenUV,
out float diffuse
)
{
const float MIN_DIFFUSE = 0.08;
const float ATTACH_SHADOW = 1.0;
const float DROP_SHADOW = 0.25;
const float AMBIENT_SHADOW = 1.0;
float4 lightScalar = tex2D(lightScalarSampler,screenUV);
normal = normalize(normal);
diffuse = saturate((dot(sunSky.mSunDir.xyz, normal) + 1)/2.0);
//diffuse = saturate(dot(sunSky.mSunDir.xyz, normal));
diffuse = lerp(1, diffuse, ATTACH_SHADOW);
}

// ---- fragment body (spliced into the generated main()) ----
In.color.rgb = pow(In.color.rgb, float3(2.2, 2.2, 2.2));
float diffuse = 0;
float3 defNormal = GetDeferredNormal(screenUV);
DataViewLighting(defNormal, screenUV, diffuse);
Current.color = In.color * make_float4(diffuse);
