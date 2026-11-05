// Shader fragment  [PS slot 17]  shLightingApply

// ---- uniform parameters ----
uniform float4 shCoeffs[16];   // reg-meta 021a02190010000000000008
uniform struct { float4 mDir; float4 mColor; } dirLightsWorld[1];   // reg-meta 021402140002000000003fc0
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

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
void SHLighting
(
float3 normal,
float3 viewVector,
inout float3 shColorDiff,
inout float3 shColorSpec,
bool   translucency
)
{
float3 x0;
float3 reflectedNormal = reflect(viewVector, normal);
if (translucency)
{
x0 = -normal;
}
else
{
x0 = reflectedNormal;
}
float3 x1 = x0 * x0;
float3 x2 = x0 * x0.yzx;
if (!kSaveInstructions)
{
shColorSpec += shCoeffs[ 9].xyz * (3 * x1.x - x1.y) * x0.y;
shColorSpec += shCoeffs[10].xyz * x1.x * x0.z;
}
shColorSpec += shCoeffs[11].xyz * (5 * x1.z - 1) * x0.y;
shColorSpec += shCoeffs[12].xyz * (5 * x1.z - 3) * x0.z;
shColorSpec += shCoeffs[13].xyz * (5 * x1.z - 1) * x0.x;
if (!kSaveInstructions)
{
shColorSpec += shCoeffs[14].xyz * (x1.x - x1.y) * x0.z;
shColorSpec += shCoeffs[15].xyz * (x1.x - 3 * x1.y) * x0.x;
}
}
float3 SHLightingGlossy16
(
float3 colorIn,
float3 normal,
float3 shColorDiff,
float3 shColorSpec,
float  glossyStrength,
float  specE,
float  specStrength,
bool   translucency
)
{
if (kSaveInstructions)
{
// specE = 4; // saves 1
// glossyStrength = 0.5; // saves 3
}
SHLighting(normal, worldCameraDirection.xyz, shColorDiff, shColorSpec, translucency);
if (translucency)
{
shColorSpec *= glossyStrength;
}
else
{
float s = glossyStrength;
shColorDiff *= 1 - s;
shColorSpec *= s;
}
colorIn *= (shColorSpec + shColorDiff);
// if (useSpecHighlight)
{
float spec = CalcBlinnPhongSpec( dirLightsWorld[0].mDir.xyz, worldCameraDirection.xyz, normal, specE );
colorIn += spec * specStrength * dirLightsWorld[0].mColor.rgb;
}
return colorIn;
}

// ---- fragment body (spliced into the generated main()) ----
float3 vertNormal  = In.texcoord<t0>.xyz;
float3 shColorDiff = In.texcoord<t1>.rgb;
float3 shColorSpec = In.texcoord<t2>.rgb;
vertNormal = normalize(vertNormal);
float3 bumpNormal = vertNormal;    
Current.color.rgb = SHLightingGlossy16(Current.color.rgb, vertNormal, shColorDiff, shColorSpec, gloss, specE, specStrength, false);
