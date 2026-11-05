// Shader fragment  [PS slot 438]  spotFogging

// ---- uniform parameters ----
uniform struct { float4 mTargetSizes; float4 mViewportSizes; float4 mNearFar;} cameraParams;   // reg-meta 022202220003000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- declarations / helper functions ----
extern uniform sampler      lightFogSampler : register( s0 );

// ---- fragment body (spliced into the generated main()) ----
// Compute intersection points. We can't simply use the cone surface position as the
// first intersection because we may be inside the light volume. These are in world
// space.
float3 entrancePoint = rayDir * tValues.x + worldCameraPosition.xyz;
float3 exitPoint = rayDir * tValues.y + worldCameraPosition.xyz;
// Current world position of visible pixel.
float3 worldPos = pos;
// Compare lengths between entry point and visible pixel, and entry point and exit point
// to determine if we hit geometry within the cone. Note that we don't just compare t-values
// because the cone geometry is larger than the mathematical cone so we get junk results
// in the volume where the geometry does not tightly bound the cone.  This is used later
// to attenuate fog if there is geometry within the fogging volume.
float len1 = length(worldPos - entrancePoint);
float len2 = length(exitPoint - entrancePoint);
float step = (tValues.y - tValues.x) / fogQuality;
float finalFogAttenuation = 0;
// Compute lighting visible due to fogging
float t = tValues.x;
for (int i = 0; i < int(fogQuality); i++)
{
// Calculate vector from light origin to position along view-ray
float3 fogPos = crwpLightPos.xyz - (rayDir * t);
float3 fogPosNormalized = normalize( fogPos );
// Calculate linear attenuation
// For distance less than falloff start, there is no lighting
float fogDistance = dot( fogPos, spotDir );
float fogAtten = falloffBias - fogDistance * denomFalloff;
fogAtten = fogAtten > 1.0f ? 0.0f : saturate(fogAtten);
// Calculate the cone attenuation
float fogAngle = dot( fogPosNormalized, spotDir );
float fogConeAtten = saturate(coneBias - fogAngle * denomCone);
finalFogAttenuation += fogAtten * fogConeAtten;
t += step;
}
finalFogAttenuation /= fogQuality;
float3 finalFogColor = float3(fogColor * diffLightColor.rgb * finalFogAttenuation * fogNoise.rgb) * fogNoise.a;
Current.color1 = float4(finalFogColor * fogStrength * saturate(len1 / len2), fogStrength * fogNoise.a);
// Debug
//Current.color1 *= 10;
//Current.color1 = float4( len1 < len2, 0, 0,1);
//Current.color1 = fogNoise;
//coneAtten
//totalAtten
//atten
