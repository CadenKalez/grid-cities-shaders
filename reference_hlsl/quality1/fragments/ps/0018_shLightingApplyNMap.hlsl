// Shader fragment  [PS slot 18]  shLightingApplyNMap

// ---- uniform parameters ----
uniform float4 shCoeffs[16];   // reg-meta 021a02190010000000000008
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[1];   // reg-meta 021402140002000000003fc0
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- declarations / helper functions ----
float3 ApplyNormalMap(float3 vertNormal, float3 vertDS, float3 nmapNormal)
{
float3 vn = normalize(vertNormal);
float3 dt = normalize(cross(vn, vertDS));
float3 ds = cross(dt, vn);
nmapNormal = normalize(nmapNormal.r * ds + nmapNormal.g * dt + nmapNormal.b * vn);
return nmapNormal;
}
const static bool diffuseUsesNmap = true;
const static bool glossyUsesNmap  = true;
const static bool useDiffuseMap   = true;     // don't apply diffuse map (make is easier to see underlying lighting)
const static bool forceDiffuse    = false;    // only show diffuse, no glossy
const static bool useSpecHighlight = (true);  // takes 6 slots
const static bool diffuseBoost    = false;   // actually saves instructions
const static bool diffuseBoost2   = false;
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
void SHLighting
(
float3 normal,
float3 viewVector,
inout float3 shColorDiff,
inout float3 shColorSpec,
bool   translucency
)
{
float3 reflectedNormal;
if (translucency)
reflectedNormal = -normal;
else
{
reflectedNormal = reflect(viewVector, normal);
}
float3 x0 = normal;
if (diffuseBoost2)
x0 = reflectedNormal;
shColorDiff = shCoeffs[0].xyz;
// use VS for this band:   shColorSpec = shCoeffs[0].xyz;
float3 shColor;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
// use VS for this band:   shColorSpec += shColor;
shColor *= kSH_A1;
shColorDiff += shColor;
if (diffuseBoost)
{
if (glossyUsesNmap)
x0 = reflectedNormal;
}
float3 x1 = x0 * x0;
float3 x2 = x0 * x0.yzx;
shColor  = shCoeffs[4].xyz  * x2.x;  // x * y
shColor += shCoeffs[5].xyz  * x2.y;  // y * z
shColor += shCoeffs[6].xyz  * (3 * x1.z - 1);
shColor += shCoeffs[7].xyz  * x2.z;  // z * x
shColor += shCoeffs[8].xyz  * (x1.x - x1.y);
// use VS for this band:   shColorSpec += shColor;
shColor *= kSH_A2;
shColorDiff += shColor;
if (!diffuseBoost || glossyUsesNmap)
{
x0 = reflectedNormal;
x1 = x0 * x0;
x2 = x0 * x0.yzx;
}
shColor  = shCoeffs[ 9].xyz * (3 * x1.x - x1.y) * x0.y;
shColor += shCoeffs[10].xyz * x1.x * x0.z;
shColor += shCoeffs[11].xyz * (5 * x1.z - 1) * x0.y;
if (true)
shColor += shCoeffs[12].xyz * (5 * x1.z - 3.00001) * x0.z;   // why 3.0001? Because the new DX compiler is shockingly buggy
else
shColor += shCoeffs[12].xyz * (5 * x1.z - 3) * x0.z;
shColor += shCoeffs[13].xyz * (5 * x1.z - 1) * x0.x;
shColor += shCoeffs[14].xyz * (x1.x - x1.y) * x0.z;
shColor += shCoeffs[15].xyz * (x1.x - 3 * x1.y) * x0.x;
shColorSpec += shColor;
}
float3 SHLightingNMap
(
float3 colorIn,
float3 normal,
float3 viewVector,
float3 shColorDiff,
float3 shColorSpec,
float  glossyStrength,
float  specE,
float  specStrength,
bool   translucency
)
{
SHLighting(normal, viewVector, shColorDiff, shColorSpec, translucency);
float s;
if (forceDiffuse)
s = 0;
else
s = glossyStrength;
if (translucency)
{
shColorSpec *= s;
}
else
{
shColorDiff *= 1 - s;
shColorSpec *= s;
}
if (useDiffuseMap)
colorIn *= shColorDiff + shColorSpec;
else
colorIn =  shColorDiff + shColorSpec;
if (useSpecHighlight)
{
float spec = CalcBlinnPhongSpec( dirLightsWorld[0].mDir.xyz, worldCameraDirection.xyz, normal, specE );
colorIn += spec * specStrength * dirLightsWorld[0].mColor.rgb;
}
return colorIn;
}

// ---- fragment body (spliced into the generated main()) ----
float3 vertNormal    = In.texcoord<t0>.xyz;
float3 shColorDiffVS = In.texcoord<t1>.rgb;
float3 shColorSpecVS = In.texcoord<t2>.rgb;
float3 bumpNormal = ApplyNormalMap(vertNormal, vertDS, nmapNormal);
Current.color.rgb  = SHLightingNMap(Current.color.rgb, bumpNormal, worldCameraDirection.xyz, shColorDiffVS, shColorSpecVS, gloss, specE, specStrength, false);
