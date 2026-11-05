// Shader fragment  [PS slot 19]  shDirectLighting

// ---- uniform parameters ----
uniform struct { float4x3 mColors4; float4 mA2; float4 mPosition[4]; } sphereLights;   // reg-meta 025702570008000000000008
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[1];   // reg-meta 021402140002000000003fc0
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- declarations / helper functions ----
float3 SHDirectLighting(float3 worldPosition, float3 worldNormal, float gloss, sampler brdfZT, int numLights = 4)
{
float4x3 normLightVector = float4x3(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
float4 r = float4(0, 0, 0, 0);
for (int i = 0; i < numLights; i++)
{
float3 lightVector = sphereLights.mPosition[i].xyz - worldPosition;
normLightVector[i] = normalize(lightVector);
r[i] = dot(normLightVector[i], lightVector);
}
float4 a2 = sphereLights.mA2;
float4 r2 = r * r;
float4 z = mul(normLightVector, worldNormal);
z = 0.5 * (z + 1);
float4 t = r / sqrt(a2 + r2);
float4x2 diffSpec = float4x2(0, 0, 0, 0, 0, 0, 0, 0);
for (int i = 0; i < numLights; i++)
diffSpec[i] = tex2D(brdfZT, float2(z[i], t[i])).rg;
float4 final = mul(diffSpec, float2(1 - gloss, gloss));
return mul(final, sphereLights.mColors4);
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
float3 SHLightingGlossy9
(
float3 colorIn,
float3 normal,
float3 shColorDiff,
float3 shColorSpec,
bool   translucency  = false
)
{
float s = glossyStrength;
shColorDiff *= 1 - s;
shColorSpec *= s;
colorIn *= (shColorSpec + shColorDiff);
return colorIn;
}
float3 SHLightingGlossy9
(
float3 colorIn,
float3 normal,
float3 shColorDiff,
float3 shColorSpec,
float  glossyStrength,
float  specE         = 1,
float  specStrength  = 0,
bool   translucency  = false
)
{
float s = glossyStrength;
shColorDiff *= 1 - s;
shColorSpec *= s;
colorIn *= (shColorSpec + shColorDiff);
float spec = CalcBlinnPhongSpec( dirLightsWorld[0].mDir.xyz, worldCameraDirection.xyz, normal, specE );
colorIn += spec * specStrength * dirLightsWorld[0].mColor.rgb;
return colorIn;
}
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}

// ---- fragment body (spliced into the generated main()) ----
float3 worldNormal   = In.texcoord<t0>;
float3 worldPosition = In.texcoord<t1>;
float4 shColorDiff   = In.texcoord<t2>;
float4 shColorSpec   = In.texcoord<t3>;
float3 bumpNormal = ApplyNormalMap(worldNormal, vertDS, nmapNormal);
worldNormal = normalize(worldNormal);
specStrength = 0;
float3 colorIn = Current.color.rgb;
float3 envLighting    = SHLightingGlossy9(colorIn, bumpNormal, shColorDiff, shColorSpec, gloss, specE, specStrength);
float3 directLighting = SHDirectLighting(worldPosition, bumpNormal, gloss, Sampler<s0>) * colorIn;
Current.color.rgb = envLighting + directLighting;
