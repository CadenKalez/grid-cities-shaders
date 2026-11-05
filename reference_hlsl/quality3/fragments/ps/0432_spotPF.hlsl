// Shader fragment  [PS slot 432]  spotPF

// ---- uniform parameters ----
uniform float4x4 clipToCamera;   // reg-meta 022902290004000000004000
uniform float4 viewFarCorners[4];   // reg-meta 02a902a90004000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

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
float2 screenUV         = In.texcoord<t0>.xy / In.texcoord<t0>.w;
float  volStrength      = In.texcoord<t0>.z;
float4 diffLightColor   = In.texcoord<t1>;
float3 crwpFarClip      = In.texcoord<t2>.xyz / In.texcoord<t0>.w;
float  doubleSided      = In.texcoord<t2>.w;
float3 crwpLightPos     = In.texcoord<t3>.xyz;
float  radius           = In.texcoord<t3>.w;
float3 spotDir          = In.texcoord<t4>.xyz;
float  innerRadius      = In.texcoord<t4>.w;
float  denomFalloff     = In.texcoord<t5>.x;
float  falloffBias      = In.texcoord<t5>.y;
float  denomCone        = In.texcoord<t5>.z;
float  coneBias         = In.texcoord<t5>.w;
float2 worldXY          = In.texcoord<t6>.xy;
// Recover falloffDist
float  falloffDist       = falloffBias / denomFalloff;

// fetch the normal and depth values
float4 normalValues = tex2D( normalSampler, screenUV );
float4 depthValues = tex2D( depthSampler, screenUV );
// recover the normal
float3 normal = normalValues.xyz * 2 - 1;
// normalize
normal = normalize( normal );
// recover the gloss
float gloss = normalValues.w;
// recover the depth
float depth = unpackDepth( depthValues.xyz );
// recover the spec power
float specPow = depthValues.w * 255.0;
// recover the direction from the camera position to the world position
float3 dir = crwpFarClip * depth;
float3 pos = dir + worldCameraPosition.xyz;
// calculate the light direction, distance and radius
float3 lightDir = crwpLightPos.xyz - dir;
float3 lightDirNormal = normalize( lightDir );
// Calculate the axial attenuation. Cutoff if we're before the falloff start.
// Formula: (falloffDist - dist) / (falloffDist - falloffStart)
float distance = dot( lightDir, spotDir );
float atten = falloffBias - distance * denomFalloff;
atten = atten > 1.0f ? 0.0f : saturate(atten);
// calculate the cone attenuation.
float coneAtten = saturate( coneBias - dot( lightDirNormal, spotDir ) * denomCone );
// calculate the diffuse lighting
float ndotl;
ndotl = dot( normal.xyz, lightDirNormal );
ndotl = lerp( saturate( ndotl ), abs( ndotl ), doubleSided );
// calculate the total attenuation
float totalAtten = ndotl * atten * coneAtten * coneAtten;
// output the result
Current.color.rgb   = diffLightColor.rgb * totalAtten;
Current.color.a     = 0;
