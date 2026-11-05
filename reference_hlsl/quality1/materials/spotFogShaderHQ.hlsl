// Material shader: spotFogShaderHQ
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 deferredInfo;
uniform float4x3 worldToCamera;
uniform float4x4 cameraToClip;
uniform float4x3 cameraToWorld;
uniform float4 cameraParams[3];
uniform float4 worldCameraPosition;
uniform float4 deferredInfo;
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4x3 modelToCamera;
uniform float4x3 modelToWorld;
uniform float4x4 cameraToClip;
uniform float4x3 cameraToWorld;
uniform float4 cameraParams[3];
uniform float4 worldCameraPosition;

void main_vertex()
{
    // --- fragment: spotVFInstanced   (cond 0000000000000000003fc0000000000000000100000001ff)
    float farClip           = cameraParams[2].y;
    float nearClip          = cameraParams[2].x + 0.01;
    float4 dlColor      = In.texcoord0;
    float4 dlParams     = In.texcoord1;
    float4 dlPos        = In.texcoord2;
    float4 dlEndPos     = In.texcoord3;
    float4 pos              = float4( modelPosition.xyz, 1 );
    float4x4 dlTransform    = float4x4(In.texcoord4, In.texcoord5, In.texcoord6, In.texcoord7);
    float4 vpos             = mul( pos, dlTransform );
    float3 vertexWorldPos   = vpos.xyz;
    vpos                    = float4( mul( vpos, worldToCamera ).xyz, 1 );
    vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
    float4 hpos             = mul( vpos, cameraToClip );
    float3 crwpLightPos     = dlPos.xyz - worldCameraPosition.xyz;
    float3 ldir             = normalize( In.texcoord6.xyz );
    float3 crwpFarClip      = vpos.xyz * farClip;
    crwpFarClip             = mul( crwpFarClip, make_float3x3(cameraToWorld) );
    float Kd                = dlParams.x;
    float Ks                = dlParams.y;
    float falloffStart      = dlParams.z;
    float falloffDist       = dlParams.w;
    // These are actually the cos of the angle
    float innerRadius       = dlEndPos.w;
    float radius            = dlPos.w;
    float volStrength       = dlEndPos.x;
    float doubleSided       = dlEndPos.y;
    // --- fragment: spotVF   (cond 0000000000000000000000000000000000000100000001ff)
    float farClip           = cameraParams[2].y;
    float nearClip          = cameraParams[2].x + 0.01;
    float4 dlColor          = deferredLight.diffColor;
    float4 pos              = float4( modelPosition.xyz, 1 );
    float3 vertexWorldPos   = mul (pos, modelToWorld).xyz;
    float4 vpos             = float4( mul( pos, modelToCamera ), 1 );
    vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
    float4 hpos             = mul( vpos, cameraToClip );
    float3 crwpLightPos     = modelToWorld[3] - worldCameraPosition.xyz;
    float3 ldir             = normalize( modelToWorld[2].xyz );
    float3 crwpFarClip      = vpos.xyz * farClip;
    crwpFarClip             = mul( crwpFarClip, make_float3x3(cameraToWorld) );
    float Kd                = deferredLight.params.x;
    float Ks                = deferredLight.params.y;
    float falloffStart      = deferredLight.params.z;
    float falloffDist       = deferredLight.params.w;
    // These are actually the cos of the angle
    float innerRadius       = deferredLight.endPosition.w;
    float radius            = deferredLight.position.w;
    float volStrength       = deferredLight.endPosition.x;
    float doubleSided       = deferredLight.endPosition.y;
}

//==============================================================================
// PIXEL SHADER  (5 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 clipToCamera;
uniform float4 viewFarCorners[4];
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
uniform struct { float4 mGammaAndFog;float4 mFogInfo;float4 mWindInfo;} userGammaAndFog;
uniform float4 gameInfo;
// Working around the fact that argscript treats ampersand as escape character.
bool AND(bool a, bool b)
{
return bool(int(a) * int(b));
}
// Returns t1, t2 first and second intersection with cone. t1 is 0 if rayOrigin is inside the cone..
// This function expects all input to be in world-space.
float2 intersectRayCone(float3 coneOrigin, float3 coneAxis, float3 rayOrigin, float3 rayDir, float coneHeight, float cosHalfAngle)
{
// http://www.geometrictools.com/LibMathematics/Intersection/Intersection.html
float AdD = dot(coneAxis, rayDir);  // 0
float cosSqr = cosHalfAngle*cosHalfAngle;   // 0.75
float3 E = rayOrigin - coneOrigin;  // -1,0,0
float AdE = dot(coneAxis, E);       // 0
float DdE = dot(rayDir, E);         // -1
float EdE = dot(E,E);               // 1
//float c2 = AdD*AdD - cosSqr;        // -0.75
//float c1 = AdD*AdE - cosSqr*DdE;    // 0.75
//float c0 = AdE*AdE - cosSqr*EdE;    // -0.75
float3 dotResults = float3(AdD, AdD, AdE);
float3 coeff = float3(AdD, AdE, AdE);
float3 sub = float3(cosSqr, cosSqr*DdE, cosSqr*EdE);
float3 cs = dotResults * coeff - sub;
//float discr = c1*c1 - c0*c2;  // 0
float discr = cs.y * cs.y - cs.z * cs.x;
float root = sqrt(max(0.0,discr));
//float invC2 = 1.0f/c2;  // -1.33333333
float invC2 = 1.0f / cs.x;
//float t2 = (-c1 - root) * invC2;  // (-0.75 - 0) * -1.33333 = 1
//float t1 = (-c1 + root) * invC2;  // (-0.75 + 0) * -1.33333 = 1
float3 ts = float3((-cs.y - root), (-cs.y + root), 0.0f) * invC2;
// Ray/plane for base intersection
float3 basePos = coneOrigin + coneAxis * coneHeight;
float3 Pn = -coneAxis;
float3 Rd = rayDir;
float Vd = dot(Pn, Rd);
float V0 = dot(basePos - rayOrigin, Pn);
//float t3 = V0 / Vd;
ts.z = V0/ Vd;
// Intersection results.
float3 r1 = rayOrigin + (rayDir * ts.y) - coneOrigin;
float3 r2 = rayOrigin + (rayDir * ts.x) - coneOrigin;
float3 r3 = rayOrigin + (rayDir * ts.z) - coneOrigin;
// Range checks; discard results above or below the cone
float dotResult = dot(r1, coneAxis);
bool b1 = AND(dotResult > 0.0f, dotResult <= coneHeight);
dotResult = dot(r2, coneAxis);
bool b2 = AND(dotResult > 0.0f, dotResult <= coneHeight);
// Discard base results outside the cone
float angle = dot(normalize(r3), coneAxis);
bool b3 = (angle >= cosHalfAngle);
// Fix t's that are behind us.
//t1 = max(t1, 0);
//t3 = max(t3, 0);
ts = max(ts, float3(0,0,0));
float2 res = float2(0,0);
//res = AND(b1, b2) ? float2(t1, t2) : res;
//res = AND(b1, b3) ? float2(t1, t3) : res;
//res = AND(b2, b3) ? float2(t3, t2) : res;
res = AND(b1, b2) ? ts.yx : res;
res = AND(b1, b3) ? ts.yz : res;
res = AND(b2, b3) ? ts.zx : res;
res.xy = res.x<=res.y ? res.xy : res.yx;  // Sort.
return res;
}
uniform struct { float4 mTargetSizes; float4 mViewportSizes; float4 mNearFar;} cameraParams;
uniform float4 worldCameraPosition;
extern uniform sampler      lightFogSampler : register( s0 );

void main_pixel()
{
    // --- fragment: spotPF   (cond 0000000000000000000000000000000000000000000000ff)
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
    // --- fragment: spotSpecPF   (cond 0102b10000000000000000000000000000000000000000ff)
    float3 toCamera = normalize( worldCameraPosition.xyz - pos.xyz );
    float3 h = normalize( lightDirNormal + toCamera );
    float ndoth = saturate( dot( normal.xyz, h ) );
    float spec = pow( ndoth, specPow );
    Current.color.a = diffLightColor.a * totalAtten * spec * gloss;
    // --- fragment: spotFoggingSetupPF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 fogColor = userGammaAndFog.mFogInfo.xyz;
    float fogQuality = userGammaAndFog.mFogInfo.w;
    float3 fogStrengthInfo = userGammaAndFog.mGammaAndFog.yzw;
    float minFogStrength = max(fogStrengthInfo.x, volStrength);
    float fogStrength = lerp(minFogStrength, fogStrengthInfo.y, fogStrengthInfo.z);
     float farClip = cameraParams.mNearFar.y;
    
    float3 rayDir = normalize(crwpFarClip);
    // Construct UV coords from pixel world position
    float2 worldUV = worldXY / 768.0f;
    // Read in animation speed multiplier
    float fogAnimSpeed = userGammaAndFog.mWindInfo.z;
    // Wind direction is passed in in view space. We then scale by the game time to get
    // our uv animation direction.
    float2 windDirViewSpace = normalize(userGammaAndFog.mWindInfo.xy) * gameInfo.x * fogAnimSpeed;
    float4 fogNoise = volStrength < 0 ? float4(1,1,1,1) : tex2D(lightFogSampler, worldUV - windDirViewSpace);
    // --- fragment: spotFoggingPixelTPF   (cond 0000000000000000000000000000000000000000000000ff)
    float3 rayOrigin = float3(0,0,0);
    float3 coneOrigin = crwpLightPos;
    float3 coneAxis = -spotDir;
    float3 cosHalfAngle = radius;
    float2 tValues = intersectRayCone(coneOrigin, coneAxis, rayOrigin, rayDir, falloffDist, cosHalfAngle);
    // --- fragment: spotFogging   (cond 0000000000000000000000000000000000000000000000ff)
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
}
