// Material shader: generic_dataview_lit
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: screenInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float hw = Current.position.w;
    // --- fragment: dataViewLightingMeshVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = In.normal.xyz;
    Current.color = In.color;
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 renderTargetInfo0;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
uniform float4 worldFarCorners[4];
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

void main_pixel()
{
    // --- fragment: screenInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    // --- fragment: dataViewLightingMeshPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 baseColor = pow(In.color.rgb, float3(2.2, 2.2, 2.2));
    float3 normal = In.texcoord<t0>.xyz;
    float3 worldViewDirection = normalize(lerp(lerp(worldFarCorners[1],worldFarCorners[0],screenUV.y),lerp(worldFarCorners[3],worldFarCorners[2],screenUV.y),screenUV.x)).xyz;;
    float3 specColor = baseColor * 3.0f;
    //bool ambientEnable = false;
    //float specE = 60;
    //float reflectance = 1; // Valid range [0,1]
    float4 finalColor = float4(DataViewLightingModified(screenUV, normal, worldViewDirection, baseColor,
    specColor), 1);
    Current.color = finalColor;
}
