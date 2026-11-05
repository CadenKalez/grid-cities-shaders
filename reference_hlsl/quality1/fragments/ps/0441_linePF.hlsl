// Shader fragment  [PS slot 441]  linePF

// ---- uniform parameters ----
uniform float4x4 clipToCamera;   // reg-meta 022902290004000000004000
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- declarations / helper functions ----
float3 mulq(float3 v, float4 q)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}
float unpackDepth( float3 packeddepth )
{
return dot( packeddepth, float3( 1, 1 / 255.0f, 1 / (255.0*255.0) ) );
}
extern uniform sampler      normalSampler   : register( s14 );
extern uniform sampler      depthSampler    : register( s15 );

// ---- fragment body (spliced into the generated main()) ----
// get values from the interpolators
float3 crwpFarClip      = In.texcoord<t0>.xyz / In.texcoord<t6>.w;
float4 diffLightColor   = In.texcoord<t1>;
float3 p0               = In.texcoord<t2>.xyz;
float  radius           = In.texcoord<t2>.w;
float  volStrength      = In.texcoord<t3>.x;
float  doubleSided      = In.texcoord<t3>.y;
float  innerRadius      = In.texcoord<t3>.w;
float  denomRadial      = In.texcoord<t4>.x;
float  radialBias       = In.texcoord<t4>.y;
float  denomFalloff     = In.texcoord<t4>.z;
float  falloffBias      = In.texcoord<t4>.w;
float3 rayNormal        = In.texcoord<t5>.xyz;
float  halfRayLen       = falloffBias / denomFalloff;
float2 screenUV         = In.texcoord<t6>.xy / In.texcoord<t6>.w;

float2 worldXY          = float2(In.texcoord<t5>.w, In.texcoord<t6>.z);
// fetch the normal and depth values
float4 normalValues = tex2D( normalSampler, screenUV );
float4 depthValues = tex2D( depthSampler, screenUV );
// recover the normal
float3 normal = normalValues.xyz * 2 - 1;
// recover the gloss
float gloss = normalValues.w;
// recover the depth
float depth = unpackDepth( depthValues.xyz );
// recover the spec power
float specPow = depthValues.w * 255.0;
// recover the direction from the camera position to the world position
float3 dir = crwpFarClip * depth;
// recover the world space camera position
float3 pos = dir + worldCameraPosition.xyz;
// calculate the light direction, distance and radius
//                   a
//   p1 <----------p3--- p0
//                  | /
//                 b|/ c
//                  x pos
//
float3 toPos = pos.xyz - p0;
float  a = dot( toPos, rayNormal );
float3 p3 = p0 + rayNormal * a;
float3 lightDir = p3 - pos.xyz;
float3 lightDirNormal = normalize( lightDir );
// calculate the diffuse lighting
float ndotl;
ndotl = dot( normal.xyz, lightDirNormal );
ndotl = lerp( saturate( ndotl ), abs( ndotl ), doubleSided );
// clip to cylinder end caps by projecting position onto axis of light and expressing it relative
// to the center of the cone. If the position is close to the end caps, we attenuate along the length.
float distFromCenter = abs(halfRayLen - a);
float endCapAttenuation = pow(saturate(falloffBias - distFromCenter * denomFalloff), 1.5);
// get the distance of pixel position and the light's principle axis.   This distance controls radial attenuation.
// If this distance exceeds the radius of the cylinder, the pixel is outside of the cylinder and receives no illumination (ie full attenuation).
// If this distance is completely within inner radius, its gets full illumination (ie no attenation )
float distanceToLightAxis = dot(lightDir, lightDir);
float radialAttenuation = saturate(radialBias - distanceToLightAxis * denomRadial);
// output the result
Current.color = radialAttenuation * radialAttenuation * endCapAttenuation * diffLightColor * ndotl;
float finalLightSpec = Current.color.a;
Current.color.a = 0.0f;
