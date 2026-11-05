// Material shader: pointQuadShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x3 worldToCamera;
uniform float4x4 worldToClip;
uniform float4 deferredInfo;
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4 viewFarCorners[4];

void main_vertex()
{
    // --- fragment: pointQuadVF   (cond 0000000000000000000000000000000000000000000000ff)
    int i                   = int(modelPosition.z);
    float2 pos              = modelPosition.xy;
    float2 screenUV         = pos.xy * deferredInfo.xy + deferredInfo.zw;
    float3 toViewFarClip    = viewFarCorners[i].xyz;
    float3 lpos             = mul( float4( deferredLight.position.xyz, 1 ), worldToCamera );
    float Kd                = deferredLight.params.x;
    float Ks                = deferredLight.params.y;
    float radius            = deferredLight.position.w;
    float innerRadius       = deferredLight.endPosition.w;
    float denom             = 1.0 / ( radius*radius - innerRadius*innerRadius );
    float2 param            = float2( -denom,  - innerRadius*innerRadius * -denom + 1 );
    float4 level            = float4( Kd, Kd, Kd, Ks );
    Current.position        = float4( pos.xy, 0, 1 );
    Current.texcoord<t0>    = float4( screenUV, 0, 0 );
    Current.texcoord<t1>    = float4( deferredLight.diffColor.rgb, 1.0 ) * level;
    Current.texcoord<t2>    = float4( toViewFarClip, 0 );
    Current.texcoord<t3>    = float4( lpos, denom );
    Current.texcoord<t4>    = float4( param, 0, innerRadius*innerRadius );
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 clipToCamera;
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
uniform float4x4 clipToModel;
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4x3 cameraToWorld;
uniform float4x3 worldToModel;
extern uniform sampler gelSampler0 : register( s0 );
extern uniform sampler gelSampler1 : register( s1 );
uniform float4x4 clipToModel;
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4x3 cameraToWorld;
uniform float4x3 worldToModel;
extern uniform sampler gelSampler : register( s0 );

void main_pixel()
{
    // --- fragment: pointQuadPF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV         = In.texcoord<t0>.xy;
    float4 diffLightColor   = In.texcoord<t1>;
    float3 toViewFarClip    = In.texcoord<t2>.xyz;
    float3 lightPos         = In.texcoord<t3>.xyz;
    float  denom            = In.texcoord<t3>.w;
    float2 param            = In.texcoord<t4>.xy;
    float  innerRadius2     = In.texcoord<t4>.w;
    float4 normalValues = tex2D( normalSampler, screenUV );
    float4 depthValues = tex2D( depthSampler, screenUV );
    float3 normal = normalValues.xyz * 2 - 1;
    normal = normalize( normal );
    float gloss = normalValues.w;
    float depth = unpackDepth( depthValues.xyz );
    float specPow = depthValues.w * 255.0;
    float3 pos = toViewFarClip * depth;
    float3 lightDir = lightPos.xyz - pos.xyz;
    float d2 = dot( lightDir, lightDir );
    float3 lightDirNormal = normalize( lightDir );
    float atten = saturate( d2 * param.x + param.y );
    float ndotl = saturate( dot( normal.xyz, lightDirNormal ) );
    Current.color   = diffLightColor * ndotl * atten;
    // --- fragment: pointSpecPF   (cond 0102b10000000000000000000000000000000000000000ff)
    float3 toCamera = normalize( worldCameraPosition.xyz - pos.xyz );
    float3 h = normalize( lightDirNormal + toCamera );
    float ndoth = saturate( dot( normal.xyz, h ) );
    float spec = pow( ndoth, specPow );
    Current.color.a = diffLightColor.a * ndotl * atten * spec * gloss;
    // --- fragment: pointGelBlendPF   (cond 0d00010000000000000000000000000000000100000001ff)
    float3 mpos = mul( float4( pos.xyz, 1 ), worldToModel );
    float4 gelValues0 = texCUBE( gelSampler0, mpos.xzy );
    float4 gelValues1 = texCUBE( gelSampler1, mpos.xzy );
    float4 gelValues = lerp( gelValues0, gelValues1, blend );
    Current.color.rgb *= gelValues.rgb;
    // --- fragment: pointGelPF   (cond 0d00000000000000000000000000000000000100000001ff)
    float3 mpos = mul( float4( pos.xyz, 1 ), worldToModel );
    float4 gelValues = texCUBE( gelSampler, mpos.xzy );
    Current.color.rgb *= gelValues.rgb;
}
