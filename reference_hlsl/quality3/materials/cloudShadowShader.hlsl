// Material shader: cloudShadowShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 clipToWorld;
uniform float4 worldCameraPosition;

void main_vertex()
{
    // --- fragment: depthInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float hw = Current.position.w;
    // --- fragment: positionInfoFromDepthQuad   (cond 0000000000000000000000000000000000000000000000ff)
    float2 coords = In.texcoord0.xy * 2 - 1;
     coords.y = -coords.y;
    float4 farPoint  = mul(float4(coords, 1, 1), clipToWorld);
    Current.texcoord<t0> = farPoint.xyz / farPoint.w - worldCameraPosition.xyz;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 renderTargetInfo0;
extern uniform sampler depthMap  : register(s15);
float UnpackDepth(float4 rgbaDepth)
{
return dot( rgbaDepth.xyz, float3( 1, 1 / 255.0, 1 / (255.0*255.0) ) );
}
uniform float4 worldCameraPosition;
uniform float4 nearFar;
uniform float4 shadowFrustumInfo;
uniform float4 gameInfo;
extern uniform sampler cloudSampler0    : register( s1 );
extern uniform sampler cloudSampler1    : register( s2 );
extern uniform sampler cloudSampler2    : register( s3 );

void main_pixel()
{
    // --- fragment: depthInfo   (cond 0000000000000000000000000000000000000000000000ff)
    float2 screenUV = (In.vpos.xy + float2(0.5, 0.5)) * renderTargetInfo0.zw;
    float4 rgbaDepth = tex2D(depthMap, screenUV);
    float depth = UnpackDepth(rgbaDepth);
    // --- fragment: positionInfoFromDepthQuad   (cond 0000000000000000000000000000000000000000000000ff)
    float3 farPoint  = In.texcoord<t0>.xyz;
    float3 viewPosition  = worldCameraPosition.xyz;
    float3 viewDirection = normalize(farPoint);
    float3 worldDistance = make_float3(depth * nearFar.y);
    float3 worldPosition = viewPosition + farPoint * depth;
    // --- fragment: cloudShadowPS   (cond 0000000000000000000000000000000000000000000000ff)
    // transform to shadow space
    float cloudHeight[3] = {200.0,230.0,350.0}; 
    float2 cloudVelocity[3] = {float2(-13,-60.0), float2(14,-49.5), float2(28.0, -88.0)}; 
    float2 cloudSize[3] = {float2(5900.0,5900.0), float2(6148.0,6148.0), float2(11096.0,11096.0)}; 
    float2 shadowPos[3];
    for( int i = 0; i < 3; i++ )
    shadowPos[i] = (worldPosition.xy + (cloudHeight[i]-worldPosition.z) * shadowFrustumInfo.xy * -1.0 + cloudVelocity[i]*gameInfo.x) / cloudSize[i];
    float shadow = 0.45+0.55*(clamp(tex2D(cloudSampler1, shadowPos[1].xy).g+tex2D(cloudSampler2, shadowPos[2].xy).b-0.5*tex2D(cloudSampler0, shadowPos[0].xy).r,0.0,1.0));
    Current.color.rgba = float4(shadow, shadow, shadow, 1);
}
