// Shader fragment  [PS slot 343]  streetpropDataViewPS

// ---- uniform parameters ----
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;   // reg-meta 028b028b000a000000000008
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008
uniform float4 worldFarCorners[4];   // reg-meta 02b602b60004000000000008

// ---- declarations / helper functions ----
float CalcPhongSpec( float3 lightDir, float3 reflectedNormal, float specE )
{
float nDotR = saturate(dot(reflectedNormal, lightDir));
specE = max(specE, 0.001f);
float spec1 = pow(nDotR, specE);
return spec1;
}
float CalcBlinnPhongSpec( float3 lightDir, float3 viewDir, float3 normal, float specE )
{
float3 halfVector = normalize(lightDir - viewDir);
float nDotH = saturate(dot(normal, halfVector));
specE = max(specE, 0.001f);
float spec = pow(nDotH, specE);
return spec;
}
float CalcBlinnPhongSchlick(float3 lightDir, float3 viewDir, float3 normal, float specE, float specF)
{
float3 halfVector = normalize(lightDir - viewDir);
float nDotH = saturate(dot(normal, halfVector));
specE = max(specE, 0.001f);
float spec = pow(nDotH, specE);
float specNormalizingFactor = (specE + 2) / 8;
float schlick = specF + (1.0f - specF) * exp2(-8.656170 * saturate(dot(lightDir, halfVector))); // 8.656170 == 1/ln(2) * 6
//float schlick = specF + (1 - specF)*pow((1 - dot(halfVector,lightDir)),5);
return spec*specNormalizingFactor*schlick;
}
extern uniform sampler lightScalarSampler : register(s13);
float3 DataViewLightingModified
(
float2 screenUV,
float3 normal,
float3 viewVector,
float3 diffuseColor,
float3 specColor
)
{
float ambientEnabled = 1.0;
float specE = 10;
float reflectance = 0.1;
float3 ambient = diffuseColor * 0.05f;
normal = normalize(normal);
float n_dot_l = saturate((dot(sunSky.mSunDir.xyz, normal) + 1.0f) * 0.5f);
//float n_dot_l = saturate(dot(sunSky.mSunDir.xyz, normal));
float spec = CalcBlinnPhongSchlick(sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance);
float3 diffuse = (diffuseColor * n_dot_l);
float3 specContrib = specColor * spec;
float4 lightScalar = tex2D(lightScalarSampler,screenUV);
float directShadow  = lightScalar.x;
float ambientShadow = lightScalar.y;
float finalShadowTerm = max(directShadow, 0.9f) * max(ambientShadow, 0.2f);
diffuse *= finalShadowTerm;
specContrib *=  finalShadowTerm;
return diffuse + specContrib + ambient * ambientEnabled;
}
float3 DataViewLightingModifiedDirect
(
float3 normal,
float3 viewVector,
float3 diffuseColor,
float3 specColor
)
{
float ambientEnabled = 1.0;
float specE = 10;
float reflectance = 0.1;
float3 ambient = diffuseColor * 0.05f;
normal = normalize(normal);
float n_dot_l = saturate((dot(sunSky.mSunDir.xyz, normal) + 1.0f) * 0.5f);
//float n_dot_l = saturate(dot(sunSky.mSunDir.xyz, normal));
float spec = CalcBlinnPhongSchlick(sunSky.mSunDir.xyz, viewVector, normal, specE, reflectance);
float3 diffuse = (diffuseColor * n_dot_l);
float3 specContrib = specColor * spec;
return diffuse + specContrib + ambient * ambientEnabled;
}

// ---- fragment body (spliced into the generated main()) ----
float3 baseColor = globalDataView.baseColor.xyz;
baseColor = pow(baseColor, float3(2.2, 2.2, 2.2));
float3 worldViewDirection = normalize(lerp(lerp(worldFarCorners[1],worldFarCorners[0],screenUV.y),
lerp(worldFarCorners[3],worldFarCorners[2],screenUV.y),screenUV.x)).xyz;
float3 normal = GetDeferredNormal(screenUV);
float3 finalColor = DataViewLightingModified(screenUV, normal, worldViewDirection, baseColor, baseColor).xyz;
Current.color = float4(finalColor, 1.0);
