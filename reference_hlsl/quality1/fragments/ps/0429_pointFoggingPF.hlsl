// Shader fragment  [PS slot 429]  pointFoggingPF

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform struct { float4 mGammaAndFog;float4 mFogInfo;float4 mWindInfo;} userGammaAndFog;   // reg-meta 02d402d40003000000000008

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
float2 tValues = In.texcoord4.zw;
// Compute intersection points. We can't simply use the cone surface position as the
// first intersection because we may be inside the light volume. These are world space.
float3 entrancePoint = rayDir * tValues.x + worldCameraPosition.xyz;
float3 exitPoint = rayDir * tValues.y + worldCameraPosition.xyz;
// Compute world-space position of the visible pixel
float3 worldPos = pos;
// Compare lengths between entry point and visible pixel, and entry point and exit point
// to determine if we hit geometry within the sphere. This is used later to attenuate fog
// if there is geometry within the fogging volume.
float len1 = length(worldPos - entrancePoint);
float len = length(exitPoint - entrancePoint);
float step = (tValues.y - tValues.x) / fogQuality;
float finalFogAttenuation = 0;
// Compute lighting visible due to fogging
float t = tValues.x;
for (int i = 0; i < int(fogQuality); i++)
{
// Calculate vector from light origin to position along view-ray
float3 fogPos = crwpLightPos.xyz - (rayDir * t);
// Calculate linear attenuation
// For distance less than falloff start, there is no lighting
float fogDistance = dot( fogPos, fogPos );
float fogAtten = saturate( falloffBias - fogDistance * denom );
finalFogAttenuation += fogAtten;
t += step;
}
finalFogAttenuation /= fogQuality;
float3 finalFogColor = float3(fogColor * diffLightColor.rgb * finalFogAttenuation * fogNoise.rgb) * fogNoise.a;
Current.color1 = float4(finalFogColor * fogStrength * saturate(len1 / len), fogStrength * fogNoise.a);
// Debugging
//Current.color1 *= 10;
//Current.color1 = float4(tValues.y /1000, 0,0,1);
