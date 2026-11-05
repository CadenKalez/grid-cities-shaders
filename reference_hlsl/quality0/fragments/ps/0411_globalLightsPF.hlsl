// Shader fragment  [PS slot 411]  globalLightsPF

// ---- uniform parameters ----
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform struct { float4 lightDir; float4 color; float4 level; float4 fillColor; float4 fillLevel; } parallel[4];   // reg-meta 02ab02ab0014000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

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
float2  screenUV            = In.texcoord0.xy;
float4  hpos                = In.texcoord1;
float4  param               = In.texcoord2;
float3  toWorldFarClip      = In.texcoord3.xyz;
float4 normalValues = tex2D( normalSampler, screenUV );
float4 depthValues = tex2D( depthSampler, screenUV );
float3 normal = normalValues.xyz * 2 - 1;
normal = normalize( normal );
float gloss = normalValues.w;
float depth = unpackDepth( depthValues.xyz );
float specPow = depthValues.w * 255.0;
float4 wpos = float4( toWorldFarClip * depth + worldCameraPosition, 1 );
float3 worldNormal = normal;
float3 toCamera = worldCameraPosition.xyz - wpos.xyz;
float  camDist = dot( toCamera, toCamera ); // length( toCamera );
float3 toCameraNormal = normalize( toCamera ); // / camDist;
float4 color0 = float4( 0, 0, 0, 0 );
float4 color1 = float4( 0, 0, 0, 0 );
float4 color2 = float4( 0, 0, 0, 0 );
Current.color = float4( 0, 0, 0, 0 );
