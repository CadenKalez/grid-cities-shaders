// Material shader: lineShaderFog
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 deferredInfo;
uniform float4x4 cameraToClip;
uniform float4x3 cameraToWorld;
uniform float4x3 worldToCamera;
uniform float4 cameraParams[3];
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4 deferredInfo;
uniform float4x3 modelToCamera;
uniform float4x3 modelToWorld;
uniform float4x4 cameraToClip;
uniform float4x3 cameraToWorld;
uniform float4x3 worldToCamera;
uniform float4 cameraParams[3];
uniform float4 worldCameraPosition;
// Working around the fact that argscript treats ampersand as escape character.
bool AND(bool a, bool b)
{
return bool(int(a) * int(b));
}
// This function generates two mutually orthogonal vectors from input
// axis (which must be normalized).
float2x3 GenerateComplementBasis(float3 w)
{
float3 u,v;
float select = float(abs(w.x) >= abs(w.y));
float invLength = rsqrt(lerp(w.y * w.y, w.x * w.x, select) + w.z * w.z);
float3 u1 = float3(-w.z * invLength, 0.0f, w.x * invLength);
float3 u2 = float3(0.0f, w.z * invLength, -w.y * invLength);
u = lerp(u2, u1, select);
v = cross(u,w);
return float2x3(u,v);
}
// Returns t1, t2 first and second intersection with cylinder. t1 is 0 if rayOrigin is inside the cylinder.
// CylinderOrigin must be the midway point between the end caps of the cylinder, along the cylinder axis.
float2 intersectRayCylinder(float3 rayOrigin, float3 rayDir, float3 cylinderOrigin, float3 cylinderAxis,
float cylinderHeight, float cylinderRadius)
{
// http://www.geometrictools.com/LibMathematics/Intersection/Intersection.html
float2x3 basis = GenerateComplementBasis(cylinderAxis);
float3 u = basis[0];
float3 v = basis[1];
float3 w = cylinderAxis;
float halfHeight = cylinderHeight * 0.5f;
float rsqr = cylinderRadius * cylinderRadius;
// Convert incoming ray origin to cylinder coordinates.
float3 diff = rayOrigin - cylinderOrigin;
float3 p = float3(dot(diff,u), dot(diff,v), dot(diff,w));
// Convert the incoming ray direction to cylinder coordinates.
float3 d = float3(dot(rayDir,u), dot(rayDir,v), dot(rayDir,w));
// Test intersection with planes of end caps. If we're inside the cylinder,
// one of the t-values will be negative.
float3 planePosTop = cylinderOrigin + (cylinderAxis * halfHeight);
float Vd = dot(rayDir, cylinderAxis);
float V0 = dot(planePosTop - rayOrigin, cylinderAxis);
float tp0 = V0 / Vd;
float3 planePosBottom = cylinderOrigin - (cylinderAxis * halfHeight);
Vd = dot(rayDir, -cylinderAxis);
V0 = dot(planePosBottom - rayOrigin, -cylinderAxis);
float tp1 = V0 / Vd;
bool intersectsTop = length((rayOrigin + rayDir * tp0) - planePosTop) <= cylinderRadius;
bool intersectsBottom = length((rayOrigin + rayDir * tp1) - planePosBottom) <= cylinderRadius;
// Test intersection with cylinder wall
float a0 = p.x * p.x + p.y * p.y - rsqr;
float a1 = p.x * d.x + p.y * d.y;
float a2 = d.x * d.x + d.y * d.y;
float discr = max(0, a1 * a1 - a0 * a2);
float root = sqrt(discr);
float inv2 = 1.0f / (a2 + 0.00000000001f);
float tc0 = (-a1 - root) * inv2;
float tc1 = (-a1 + root) * inv2;
// Intersection results
float3 rc0 = rayOrigin + rayDir * tc0;
float3 rc1 = rayOrigin + rayDir * tc1;
// Check bounds of cylinder wall t-values as that tests against the infinite cylinder wall.
bool b1 = abs(dot(rc0 - cylinderOrigin, cylinderAxis)) <= halfHeight;
bool b2 = abs(dot(rc1 - cylinderOrigin, cylinderAxis)) <= halfHeight;
tc0 = max(tc0, 0);
tc1 = max(tc1, 0);
tp0 = max(tp0, 0);
tp1 = max(tp1, 0);
// Determine results. Only four cases:
//      1. End-to-end.
//      2. Wall-to-end cap.
//      3. Wall-to-top cap.
//      4. Wall-to-wall.
float2 res = float2(tc0, tc1);
res = AND(intersectsTop, intersectsBottom) ? float2(tp0, tp1) : res;
res = AND(AND(intersectsTop, !intersectsBottom),b1) ? float2(tp0, tc0) : res;
res = AND(AND(intersectsTop, !intersectsBottom),b2) ? float2(tp0, tc1) : res;
res = AND(AND(!intersectsTop, intersectsBottom),b1) ? float2(tp1, tc0) : res;
res = AND(AND(!intersectsTop, intersectsBottom),b2) ? float2(tp1, tc1) : res;
// Sort
res.xy = res.x<=res.y ? res.xy : res.yx;
return res;
//return float2(intersectsTop, intersectsBottom);
}

void main_vertex()
{
    // --- fragment: lineVFInstanced   (cond 0000000000000000003fc0000000000000000100000001ff)
    float farClip           = cameraParams[2].y;
    float nearClip          = cameraParams[2].x + 0.01;
    float4 dlPos = In.texcoord2;
    float4 dlParams = In.texcoord1;
    float4 dlEndPos = In.texcoord3;
    float4 dlColor = In.texcoord0;
    float4  pos             = float4( modelPosition.xyz, 1 );
    float4x4 dlTransform    = float4x4(In.texcoord4, In.texcoord5, In.texcoord6, In.texcoord7);
    float4 vpos             = mul( pos, dlTransform );
    float4 vertexWorldPos   = vpos;
    vpos                    = float4( mul( vpos, worldToCamera ), 1 );
    vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
    float4 hpos             = mul( vpos, cameraToClip );
    float3 crwp             = vpos.xyz * farClip;
    crwp                    = mul( crwp, make_float3x3(cameraToWorld) );
    float3  p0              = dlPos.xyz;
    float3  p1              = dlEndPos.xyz;
    float   radius          = dlPos.w;
    float   radius2         = radius * radius;
    float   innerRadius     = dlEndPos.w;
    float   innerRadius2    = innerRadius * innerRadius;
    float   Kd              = dlParams.x;
    float   Ks              = dlParams.y;
    float   volStrength     = dlParams.z;
    float   doubleSided     = dlParams.w;
    // --- fragment: lineVF   (cond 0000000000000000000000000000000000000100000001ff)
    float farClip           = cameraParams[2].y;
    float nearClip          = cameraParams[2].x + 0.01;
    
    float4  pos             = float4( modelPosition.xyz, 1 );
    
    
            float3  vertexWorldPos  = mul(pos, modelToWorld);
            float4  vpos            = float4( mul( pos, modelToCamera ), 1 );
    vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
    float4 hpos             = mul( vpos, cameraToClip );
    float3 crwp             = vpos.xyz * farClip;
    crwp                    = mul( crwp, make_float3x3(cameraToWorld) );
    float3  p0              = deferredLight.position.xyz;
    float3  p1              = deferredLight.endPosition.xyz;
    float   radius          = deferredLight.position.w;
    float   radius2         = radius * radius;
    float   innerRadius     = deferredLight.endPosition.w;
    float   innerRadius2    = innerRadius * innerRadius;
    float   Kd              = deferredLight.params.x;
    float   Ks              = deferredLight.params.y;
    float   volStrength     = deferredLight.params.z;
    float   doubleSided     = deferredLight.params.w;
    // --- fragment: lineTexcoordOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    float3  ray             = p1 - p0;
    float3  rayNormal       = normalize( ray );
    float   rayLen          = length( ray );
    float   halfRayLen      = rayLen * 0.5f;
    float4  level           = float4( Kd, Kd, Kd, Ks );
    float endCapFallOffPercent = 0.65f; //if within this percentage from end of cylinder, we attenuate along primary axis
    float denom             = 1.0 / ( radius2 - innerRadius2 );
    float denomFalloff      = 1.0 / (halfRayLen - halfRayLen * endCapFallOffPercent);
    Current.position        = hpos;
    Current.texcoord<t0>    = float4( crwp.xyz, 0 );            //.w used by volumetric
    Current.texcoord<t1>    = float4( dlColor.rgb, 1 ) * level; //.w used by volumetric
    Current.texcoord<t2>    = float4( p0, radius );
    Current.texcoord<t3>    = float4( volStrength, doubleSided, 0, innerRadius );
    Current.texcoord<t4>    = float4( denom, radius2 * denom, denomFalloff, halfRayLen * denomFalloff );
    Current.texcoord<t5>    = float4( rayNormal, vertexWorldPos.x );
    Current.texcoord<t6>    = float4( hpos.xy * deferredInfo.xy + deferredInfo.zw * hpos.w, vertexWorldPos.y, hpos.w );
    // --- fragment: lineFoggingVF   (cond 0000000000000000000000000000000000000000000000ff)
    float height = length(ray);
    float3 rayOrigin = worldCameraPosition.xyz;
    float3 rayDir = normalize(vertexWorldPos.xyz - rayOrigin);
    float3 cylinderOrigin = p0 + rayNormal * height * 0.5f;
    float3 cylinderAxis = rayNormal;
    float cylinderRadius = radius;
    float2 tValues = intersectRayCylinder(rayOrigin, rayDir, cylinderOrigin, cylinderAxis, height, cylinderRadius);
    Current.texcoord0.w = tValues.x;
    Current.texcoord1.w = tValues.y;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 clipToCamera;
uniform float4 deferredInfo;
uniform float4 worldCameraPosition;
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
uniform struct { float4 mGammaAndFog;float4 mFogInfo;float4 mWindInfo;} userGammaAndFog;
uniform float4 gameInfo;
extern uniform sampler      lightFogSampler : register( s0 );

void main_pixel()
{
    // --- fragment: linePF   (cond 0000000000000000000000000000000000000000000000ff)
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
    // --- fragment: lineSpecPF   (cond 0102b10000000000000000000000000000000000000000ff)
    float3 npos = normalize( pos.xyz );
    float3 h = normalize( lightDirNormal - npos );
    float ndoth = saturate( dot( normal.xyz, h ) );
    float spec = pow( ndoth, specPow );
    Current.color.a = finalLightSpec * spec * gloss;
    // --- fragment: lineFoggingPF   (cond 0000000000000000000000000000000000000000000000ff)
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
}
