// Material shader: spotQuadShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;
uniform float4 deferredInfo;
uniform float4x3 modelToCamera;
uniform float4 viewFarCorners[4];

void main_vertex()
{
    // --- fragment: spotQuadVF   (cond 0000000000000000000000000000000000000000000000ff)
    int i                   = int(modelPosition.z);
    float2 pos              = modelPosition.xy;
    float2 screenUV         = pos.xy * deferredInfo.xy + deferredInfo.zw;
    float3 toViewFarClip    = viewFarCorners[i].xyz;
    float3 lpos             = modelToCamera[3];
    float3 ldir             = normalize( modelToCamera[2].xyz );
    float Kd                = deferredLight.params.x;
    float Ks                = deferredLight.params.y;
    float falloffStart      = deferredLight.params.z;
    float falloffDist       = deferredLight.params.w;
    float radius            = deferredLight.position.w;
    float innerRadius       = deferredLight.endPosition.w;
    float denomFalloff      = 1.0 / ( falloffDist - falloffStart + 0.0001 );
    float denomCone         = 1.0 / ( innerRadius - radius + 0.0001 );
    float4 param            = float4( -denomFalloff, -falloffStart * -denomFalloff + 1, denomCone, 1 - innerRadius * denomCone );
    float4 level            = float4( Kd, Kd, Kd, Ks );
    Current.position        = float4( pos.xy, 0, 1 );
    Current.texcoord<t0>    = float4( screenUV, 0, 0 );
    Current.texcoord<t1>    = float4( deferredLight.diffColor.rgb, 1.0 ) * level;
    Current.texcoord<t2>    = float4( toViewFarClip, 0 );
    Current.texcoord<t3>    = float4( lpos, radius );
    Current.texcoord<t4>    = float4( ldir, innerRadius );
    Current.texcoord<t5>    = param;
}

//==============================================================================
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 deferredInfo;
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

void main_pixel()
{
    // --- fragment: spotQuadPF   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV         = In.texcoord<t0>.xy;
    float4 diffLightColor   = In.texcoord<t1>;
    float3 toViewFarClip    = In.texcoord<t2>.xyz;
    float3 lightPos         = In.texcoord<t3>.xyz;
    float  radius           = In.texcoord<t3>.w;
    float3 spotDir          = In.texcoord<t4>.xyz;
    float  innerRadius      = In.texcoord<t4>.w;
    float4 param            = In.texcoord<t5>;
    float4 normalValues = tex2D( normalSampler, screenUV );
    float4 depthValues = tex2D( depthSampler, screenUV );
    float3 normal = normalValues.xyz * 2 - 1;
    float gloss = normalValues.w;
    float depth = unpackDepth( depthValues.xyz );
    float specPow = depthValues.w * 255.0;
    float3 pos = toViewFarClip * depth;
    float3 lightDir = lightPos - pos.xyz;
    float3 lightDirNormal = normalize( lightDir );
    float atten = saturate( dot( lightDir, spotDir ) * param.x + param.y );
    float coneAtten = saturate( dot( lightDirNormal, spotDir ) * param.z + param.w );
    float ndotl = saturate( dot( normal.xyz, lightDirNormal ) );
    float totalAtten = atten * coneAtten; // needed by SpecPF
    Current.color   = diffLightColor * ndotl * totalAtten;
    // --- fragment: spotSpecPF   (cond 0102b10000000000000000000000000000000000000000ff)
    float3 toCamera = normalize( worldCameraPosition.xyz - pos.xyz );
    float3 h = normalize( lightDirNormal + toCamera );
    float ndoth = saturate( dot( normal.xyz, h ) );
    float spec = pow( ndoth, specPow );
    Current.color.a = diffLightColor.a * totalAtten * spec * gloss;
}
