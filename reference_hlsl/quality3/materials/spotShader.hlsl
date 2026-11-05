// Material shader: spotShader
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
    // --- fragment: spotTexcoordOutputVF   (cond 0000000000000000000000000000000000000000000000ff)
    float denomFalloff      = 1.0 / ( falloffDist - falloffStart + 0.0001 );
    float denomCone         = 1.0 / ( radius - innerRadius + 0.0001 );
    float4 level            = float4( Kd, Kd, Kd, Ks );
    Current.position        = hpos;
    Current.texcoord<t0>    = float4( hpos.xy * deferredInfo.xy + deferredInfo.zw * hpos.w, volStrength, hpos.w );
    Current.texcoord<t1>    = float4( dlColor.rgb, 1.0 ) * level;
    Current.texcoord<t2>    = float4( crwpFarClip.xyz, doubleSided );
    Current.texcoord<t3>    = float4( crwpLightPos, radius );
    Current.texcoord<t4>    = float4( ldir, innerRadius );
    Current.texcoord<t5>    = float4( denomFalloff, falloffDist * denomFalloff, denomCone, radius * denomCone );
    Current.texcoord<t6>    = float4( vertexWorldPos.xy, 0, 0); //.zw is used by volumetric when it is enabled.
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
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
}
