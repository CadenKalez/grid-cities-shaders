// Shader fragment  [PS slot 423]  cloudShadowPS

// ---- uniform parameters ----
uniform float4 shadowFrustumInfo;   // reg-meta 02c302c30001000000000008
uniform float4 gameInfo;   // reg-meta 024802480001000000000008

// ---- declarations / helper functions ----
extern uniform sampler cloudSampler0    : register( s1 );
extern uniform sampler cloudSampler1    : register( s2 );
extern uniform sampler cloudSampler2    : register( s3 );

// ---- fragment body (spliced into the generated main()) ----
// transform to shadow space
float cloudHeight[3] = {200.0,230.0,350.0}; 
float2 cloudVelocity[3] = {float2(-13,-60.0), float2(14,-49.5), float2(28.0, -88.0)}; 
float2 cloudSize[3] = {float2(5900.0,5900.0), float2(6148.0,6148.0), float2(11096.0,11096.0)}; 
float2 shadowPos[3];
for( int i = 0; i < 3; i++ )
shadowPos[i] = (worldPosition.xy + (cloudHeight[i]-worldPosition.z) * shadowFrustumInfo.xy * -1.0 + cloudVelocity[i]*gameInfo.x) / cloudSize[i];
float shadow = 0.45+0.55*(clamp(tex2D(cloudSampler1, shadowPos[1].xy).g+tex2D(cloudSampler2, shadowPos[2].xy).b-0.5*tex2D(cloudSampler0, shadowPos[0].xy).r,0.0,1.0));
Current.color.rgba = float4(shadow, shadow, shadow, 1);
