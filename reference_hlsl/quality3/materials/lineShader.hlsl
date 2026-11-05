// Material shader: lineShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
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
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
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
}
