// Shader fragment  [VS slot 265]  pointQuadVF

// ---- uniform parameters ----
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4 viewFarCorners[4];   // reg-meta 02a902a90004000000000008

// ---- fragment body (spliced into the generated main()) ----
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
