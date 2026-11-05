// Shader fragment  [VS slot 230]  regionDecalProject

// ---- uniform parameters ----
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform struct { float4x3 transform; float4 projMat[3]; float4 texTransform; } regionDecalInfo[16];   // reg-meta 02d502d50070000000000008

// ---- fragment body (spliced into the generated main()) ----
const float4 wAxis = float4( 0.0f, 0.0f, 0.0f, 1.0f );
int decalIndex = toInt(Current.indices.x);
float3x4 modelToTexture = float3x4(
regionDecalInfo[ decalIndex ].projMat[0],
regionDecalInfo[ decalIndex ].projMat[1],
regionDecalInfo[ decalIndex ].projMat[2] );
// To clip space
float3 worldPos  = mul( float4( Current.position.xyz, 1.0f ), regionDecalInfo[ decalIndex ].transform );
Current.position = mul( float4( worldPos, 1.0f ), worldToClip );
// grab camera to world matrix
float4x4 cameraToWorld44 = float4x4( transpose( cameraToWorld ), wAxis );
float4x4 cameraToTexture = mul( float4x4( modelToTexture, wAxis ), cameraToWorld44 );
// cameraToWorld * modelToTexture
Current.texcoord<t1> = cameraToTexture[0];
Current.texcoord<t2> = cameraToTexture[1];
Current.texcoord<t3> = cameraToTexture[2];
// texture transform
Current.texcoord<t0> = regionDecalInfo[ decalIndex ].texTransform;
