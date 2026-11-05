// Material shader: pointShaderFog
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 deferredInfo;
uniform float4x3 worldToCamera;
uniform float4x4 cameraToClip;
uniform float4x3 cameraToWorld;
uniform float4 cameraParams[3];
uniform float4 worldCameraPosition;
uniform float4 deferredInfo;
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4x3 worldToCamera;
uniform float4x4 cameraToClip;
uniform float4x3 cameraToWorld;
uniform float4 cameraParams[3];
uniform float4 worldCameraPosition;
uniform float4 worldCameraPosition;
// Returns t1, t2 first and second intersection with sphere. t1 is 0 if rayOrigin is inside the sphere.
float2 intersectRaySphere(float3 rayOrigin, float3 rayDir, float3 sphereOrigin, float radius)
{
// http://wiki.cgsociety.org/index.php/Ray_Sphere_Intersection
float3 diff = rayOrigin - sphereOrigin;
float a = dot(rayDir, rayDir);
float b = 2.0f * dot(diff, rayDir);
float c = dot(diff, diff) - (radius * radius);
// Because we aren't using this function in the arbitrary, general sense, we know that we always have
// at least one intersection with the sphere so we don't need to check to for non-negative discriminant.
float discriminant = (b * b) - (4.0f * a * c);
float discrSqrt = sqrt(discriminant);
float q = b < 0.0f ? (-b + discrSqrt) * 0.5f : (-b - discrSqrt) * 0.5f;
float t1 = max(0, q / a);
float t2 = c / q;
float2 res = float2(t1,t2);
res.xy = res.x<res.y ? res.xy : res.yx;  // Sort.
return res;
}

void main_vertex()
{
    // --- fragment: pointVFInstanced   (cond 00000000000000000003c0000000000000000100000001ff)
    float nearClip          = cameraParams[2].x + 0.01;
    float farClip           = cameraParams[2].y;
    float4 dlPos = In.texcoord2;
    float4 dlParams = In.texcoord1;
    float4 dlEndPos = In.texcoord3;
    float4 dlColor = In.texcoord0;
    float4 pos              = float4( modelPosition.xyz * dlPos.w + dlPos.xyz, 1 );
    float4 vpos             = float4( mul( pos, worldToCamera ), 1 );
    vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
    float4 hpos             = mul( vpos, cameraToClip );
    float3 crwpLightPos     = dlPos.xyz - worldCameraPosition.xyz;
    float3 crwpFarClip      = vpos.xyz * farClip;
    crwpFarClip             = mul( crwpFarClip, make_float3x3(cameraToWorld) );
    crwpFarClip             /= vpos.z;
    float Kd                = dlParams.x;
    float Ks                = dlParams.y;
    float radius            = dlPos.w;
    float innerRadius       = dlEndPos.w;
    float volStrength       = dlEndPos.x;
    float doubleSided       = dlEndPos.y;
    float radiusSqr         = radius * radius;
    float denom             = 1.0 / ( radiusSqr - innerRadius*innerRadius );
    // Final attenuation calculation is:
    // (radius - radiusAtPixel) / (radius - innerRadius)
    float4 level            = float4( Kd, Kd, Kd, Ks );
    Current.position        = hpos;
    Current.texcoord<t0>    = float4( hpos.xy * deferredInfo.xy + deferredInfo.zw * hpos.w, denom, hpos.w );
    Current.texcoord<t1>    = float4( dlColor.rgb, 1.0 ) * level;
    Current.texcoord<t2>    = float4( crwpFarClip.xyz * hpos.w, volStrength );
    Current.texcoord<t3>    = float4( crwpLightPos, radiusSqr * denom );
    Current.texcoord<t4>    = float4( pos.xy, 0, 0 ); //.zw used by volumetric lighting
    Current.texcoord<t5>    = float4( doubleSided, 0, 0, 0 );
    // --- fragment: pointVF   (cond 0000000000000000000000000000000000000100000001ff)
    float nearClip          = cameraParams[2].x + 0.01;
    float farClip           = cameraParams[2].y;
    float4 pos              = float4( modelPosition.xyz * deferredLight.position.w + deferredLight.position.xyz, 1 );
    float4 vpos             = float4( mul( pos, worldToCamera ), 1 );
    vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
    float4 hpos             = mul( vpos, cameraToClip );
    float3 crwpLightPos     = deferredLight.position.xyz - worldCameraPosition.xyz;
    float3 crwpFarClip      = vpos.xyz * farClip;
    crwpFarClip             = mul( crwpFarClip, make_float3x3(cameraToWorld) );
    crwpFarClip             /= vpos.z;
    float Kd                = deferredLight.params.x;
    float Ks                = deferredLight.params.y;
    float radius            = deferredLight.position.w;
    float innerRadius       = deferredLight.endPosition.w;
    float volStrength       = deferredLight.endPosition.x;
    float radiusSqr         = radius * radius;
    float denom             = 1.0 / ( radiusSqr - innerRadius*innerRadius );
    // Final attenuation calculation is:
    // (radius - radiusAtPixel) / (radius - innerRadius)
    float4 level            = float4( Kd, Kd, Kd, Ks );
    Current.position        = hpos;
    Current.texcoord<t0>    = float4( hpos.xy * deferredInfo.xy + deferredInfo.zw * hpos.w, denom, hpos.w );
    Current.texcoord<t1>    = float4( deferredLight.diffColor.rgb, 1.0 ) * level;
    Current.texcoord<t2>    = float4( crwpFarClip.xyz * hpos.w, volStrength );
    Current.texcoord<t3>    = float4( crwpLightPos, radiusSqr * denom );
    Current.texcoord<t4>    = float4( pos.xy, 0, 0 ); //.zw used by volumetric lighting
    Current.texcoord<t5>    = float4( deferredLight.endPosition.y, 0, 0, 0 );
    // --- fragment: pointFoggingVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 rayOrigin = worldCameraPosition.xyz;
    float3 rayDir = normalize(pos.xyz - worldCameraPosition.xyz);
    float3 sphereOrigin = crwpLightPos + worldCameraPosition.xyz;
    // 1.1 is a magic tuning factor for spheres. Because we do this per-vertex, low
    // tessellation geometry can result in junk results where the vertices don't lie
    // exactly on the sphere surface so we compensate by expanding our actual sphere.
    float sphereRadius = radius * 1.1f;
    float2 tValues = intersectRaySphere(rayOrigin, rayDir, sphereOrigin, radius * 1.1f);
    Current.texcoord4.zw = tValues;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 clipToCamera;
uniform float4 worldCameraPosition;
uniform float4 worldCameraDirection;
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
uniform float4 worldCameraPosition;
uniform float4 worldCameraPosition;
uniform float4 gameInfo;
uniform struct { float4 mGammaAndFog;float4 mFogInfo;float4 mWindInfo;} userGammaAndFog;
extern uniform sampler      lightFogSampler : register( s0 );

void main_pixel()
{
    // --- fragment: pointPF   (cond 0000000000000000000000000000000000000000000000ff)
    float2  screenUV        = In.texcoord<t0>.xy / In.texcoord<t0>.w;
    float   denom           = In.texcoord<t0>.z;
    float4  diffLightColor  = In.texcoord<t1>;
    float3  crwpFarClip     = In.texcoord<t2>.xyz / In.texcoord<t0>.w;
    float   volStrength     = In.texcoord<t2>.w;
    float3  crwpLightPos    = In.texcoord<t3>.xyz;
    float   falloffBias     = In.texcoord<t3>.w;
    float2  worldXY         = In.texcoord<t4>.xy;
    float   doubleSided     = In.texcoord<t5>.x;
    
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
    // recover the vector from the world space camera position to the world space position
    float3 dir = crwpFarClip * depth;
    // recover the world space position
    // note: these units are too big for float precision
    // this is not used here, but used in spec and gel below
    float3 pos = dir + worldCameraPosition.xyz;
    // calculate the light direction, distance and radius
    float3 lightDir = crwpLightPos.xyz - dir.xyz;
    float d2 = dot( lightDir, lightDir );
    float3 lightDirNormal = normalize( lightDir );
    // calculate the attenuation
    float atten = saturate( falloffBias - d2 * denom);
    // calculate the diffuse lighting
    float ndotl;
    ndotl = dot( normal.xyz, lightDirNormal );
    ndotl = lerp( saturate( ndotl ), abs( ndotl ), doubleSided );
    // output the result
    Current.color.rgb = diffLightColor.rgb * ndotl * atten * atten;
    Current.color.a = 0;
    // --- fragment: pointSpecPF   (cond 0102b10000000000000000000000000000000000000000ff)
    float3 toCamera = normalize( worldCameraPosition.xyz - pos.xyz );
    float3 h = normalize( lightDirNormal + toCamera );
    float ndoth = saturate( dot( normal.xyz, h ) );
    float spec = pow( ndoth, specPow );
    Current.color.a = diffLightColor.a * ndotl * atten * spec * gloss;
    // --- fragment: pointFoggingPF   (cond 0000000000000000000000000000000000000000000000ff)
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
}
