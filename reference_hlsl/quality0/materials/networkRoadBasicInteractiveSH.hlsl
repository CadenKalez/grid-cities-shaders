// Material shader: networkRoadBasicInteractiveSH
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 modelToWorld;
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: worldSpaceNormalTangent   (cond 0000000000000000000000000000000000000000000000ff)
    float3 worldNormal  = mul(Current.normal.xyz,  make_float3x3(modelToWorld));
    float3 worldTangent = mul(Current.tangent.xyz, make_float3x3(modelToWorld));
    worldNormal  = normalize(worldNormal);
    worldTangent = normalize(worldTangent);
    float3 worldBinormal = cross(worldTangent, worldNormal);
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: networkRoadBasicDefaultVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = float3( In.texcoord0.xy, 0.0f );
    Current.texcoord<t1>.xyz = In.texcoord1.xyz;
    Current.texcoord<t2>.xyz = worldPosition.xyz;
    Current.texcoord<t3>.xyz = worldTangent;
    Current.texcoord<t4>.xyz = worldNormal;
}

//==============================================================================
// PIXEL SHADER  (6 fragments; each may be conditionally enabled)
//==============================================================================
sampler2D diffuseSampler        : register(s0);
sampler2D normalMapSampler      : register(s1);
sampler2D specSampler           : register(s2);
sampler2D noiseMaskSampler      : register(s3);
uniform float4 materialColor;
uniform struct cSunSkyInfo { float4 mPerezA; float4 mPerezB; float4 mPerezC; float4 mPerezD; float4 mPerezE; float4 mInvDensity; float4 mSunDir; float4 mZenith; float4 mSunColor; float4 mSkyColorTuning; float4 mDynamicWeather; } sunSky;
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}
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

void main_pixel()
{
    // --- fragment: networkRoadBasicMaterialSetup   (cond 0000000000000000000000000000000000000000000000ff)
    float2 baseUV        = In.texcoord<t0>.xy;
    float3 tileUV        = In.texcoord<t1>.xyz;
    float3 worldPosition = In.texcoord<t2>.xyz;
    float3 worldTangent  = In.texcoord<t3>.xyz;
    // --- fragment: networkRoadBasicBaseColor   (cond 0000000000000000000000000000000000000000000000ff)
    float4 v4Diffuse = tex2D( diffuseSampler, baseUV );
    float4 v4NoiseMask = tex2D( noiseMaskSampler, float2(tileUV.x, tileUV.y/96.0) );
    clip(v4Diffuse.a - 0.75); 
    float noiseAlpha = v4NoiseMask.a * saturate(saturate(tileUV.z / 48.0f) * (abs(frac(worldPosition.x/73.0)-0.5) * abs(frac(worldPosition.y/87.0)-0.5) * 4 + 0.65));
    Current.color.rgb = lerp(v4Diffuse.rgb,v4NoiseMask.rgb,noiseAlpha) * materialColor.rgb;
    Current.color.w = materialColor.a;
    // --- fragment: networkRoadBasicNormalMapPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 normalMap = tex2D( normalMapSampler, baseUV );
    float3 nmapNormal;
    nmapNormal.xy = normalMap.ga * 2.0f - 0.9985f;
    nmapNormal.z  = sqrt( saturate( 1.0f - dot( nmapNormal.xy, nmapNormal.xy ) ) );
    // --- fragment: networkRoadBasicSpecMapPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 specMap      = tex2D( specSampler, baseUV ).rgb;
    float  specE        = ( specMap.r * specMap.r * specMap.r + 1.0f / 1024.0f ) * 1024.0f;
    float  specStrength = specMap.b;
    float  gloss        = specMap.r;
    // --- fragment: networkRoadBasicDefaultPS   (cond 0000000000000000000000000000000000000000000000ff)
    float3 vertDS = worldTangent;
    // --- fragment: networkRoadBasicInteractiveLighting   (cond 0000000000000000000000000000000000000000000000ff)
    float3 worldNormal = In.texcoord<t0>.xyz;
    float3 bumpNormal = ApplyNormalMap(worldNormal, vertDS, nmapNormal);
    float n_dot_l = saturate((dot(sunSky.mSunDir.xyz, bumpNormal) + 1.0f) * 0.5f);
    Current.color.rgb *= n_dot_l;
}
