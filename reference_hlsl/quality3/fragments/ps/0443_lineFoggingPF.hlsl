// Shader fragment  [PS slot 443]  lineFoggingPF

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform struct { float4 mGammaAndFog;float4 mFogInfo;float4 mWindInfo;} userGammaAndFog;   // reg-meta 02d402d40003000000000008
uniform float4 gameInfo;   // reg-meta 024802480001000000000008

// ---- declarations / helper functions ----
extern uniform sampler      lightFogSampler : register( s0 );

// ---- fragment body (spliced into the generated main()) ----
float3 fogColor = userGammaAndFog.mFogInfo.xyz;
float fogQuality = userGammaAndFog.mFogInfo.w;
float3 fogStrengthInfo = userGammaAndFog.mGammaAndFog.yzw;
float minFogStrength = max(fogStrengthInfo.x, volStrength);
float fogStrength = lerp(minFogStrength, fogStrengthInfo.y, fogStrengthInfo.z);
float3 rayDir = normalize(crwpFarClip);
// Construct UV coords from pixel world position
float2 worldUV = worldXY / 768.0f;
// Read in animation speed multiplier
float fogAnimSpeed = userGammaAndFog.mWindInfo.z;
// Wind direction is passed in in view space. We then scale by the game time to get
// our uv animation direction.
float2 windDirViewSpace = normalize(userGammaAndFog.mWindInfo.xy) * gameInfo.x * fogAnimSpeed;
float4 fogNoise = volStrength < 0 ? float4(1,1,1,1) : tex2D(lightFogSampler, worldUV - windDirViewSpace);
float2 tValues = float2(In.texcoord0.w, In.texcoord1.w);
// Compute intersection points. We can't simply use the cone surface position as the
// first intersection because we may be inside the light volume. These are in world space.
float3 entrancePoint = rayDir * tValues.x + worldCameraPosition.xyz;
float3 exitPoint = rayDir * tValues.y + worldCameraPosition.xyz;
// Curent world-space position of the visible pixel
float3 worldPos = pos;
// Compare lengths between entry point and visible pixel, and entry point and exit point
// to determine if we hit geometry within the cone. Note that we don't use just compare t-values
// because the cone geometry is larger than the mathematical cone so we get junk results
// in the volume where the geometry does not tightly bound the cone.
float len1 = length(worldPos - entrancePoint);
float len2 = length(exitPoint - entrancePoint);
float step = len2 / fogQuality;
float finalFogAttenuation = 0;
// Compute lighting visible due to fogging
float t = tValues.x;
for (int i = 0; i < int(fogQuality); i++)
{
// Calculate world position along view-ray
float3 fogPos = (rayDir * t) + worldCameraPosition.xyz;
float3 toFogPos = fogPos.xyz - p0;
float  f = dot( toFogPos, rayNormal );
float3 fp3 = p0 + rayNormal * f;
float3 fogToCylinderDir = fp3 - fogPos.xyz;
float fogDistFromCenter = abs(halfRayLen - f);
// Radial attenuation
float fogDistanceToLightAxis = dot( fogToCylinderDir, fogToCylinderDir );
float fogRadialAttenuatation = saturate( radialBias - fogDistanceToLightAxis * denomRadial);
// Axial attenuation, namely if we're close to one of the end caps, we attenuate.
float fogEndCapAttenuation = saturate(falloffBias - fogDistFromCenter * denomFalloff);
finalFogAttenuation +=  fogRadialAttenuatation *  fogEndCapAttenuation;
t += step;
}
finalFogAttenuation /= fogQuality;
const float LINE_LIGHT_FOG_STRENGTH = 1.5f;
float3 finalFogColor = float3(fogColor * diffLightColor.rgb * finalFogAttenuation * fogNoise.rgb) * fogNoise.a;
Current.color1 = float4(finalFogColor * fogStrength * saturate(len1 / len2), fogStrength * fogNoise.a) * LINE_LIGHT_FOG_STRENGTH;
// Debugging
//Current.color1 *= 10;
//Current.color1 = float4(1,0,0, 1);
