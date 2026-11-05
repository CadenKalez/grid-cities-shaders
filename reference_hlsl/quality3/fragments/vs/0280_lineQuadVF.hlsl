// Shader fragment  [VS slot 280]  lineQuadVF

// ---- uniform parameters ----
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4 viewFarCorners[4];   // reg-meta 02a902a90004000000000008

// ---- fragment body (spliced into the generated main()) ----
int     i               = int(modelPosition.z);
float2  pos             = modelPosition.xy;
float2  screenUV        = pos.xy * deferredInfo.xy + deferredInfo.zw;
float3  toViewFarClip   = viewFarCorners[i].xyz;
float3  p0              = mul( float4( deferredLight.position.xyz, 1 ), worldToCamera );
float3  p1              = mul( float4( deferredLight.endPosition.xyz, 1 ), worldToCamera );
float   radius          = deferredLight.position.w;
float   radius2         = radius * radius;
float   innerRadius     = deferredLight.endPosition.w;
float   innerRadius2    = innerRadius * innerRadius;
float3  aline           = p1 - p0;
float3  lineNormal      = normalize( aline );
p0                      += lineNormal * radius;
p1                      -= lineNormal * radius;
float   Kd              = deferredLight.params.x;
float   Ks              = deferredLight.params.y;
float4  level           = float4( Kd, Kd, Kd, Ks );
float denom             = 1.0 / ( radius2 - innerRadius2 );
float3  ray             = p1 - p0;
float3  rayNormal       = normalize( ray );
float   rayLen2         = dot( ray, ray );
float4 hpos             = float4(0,0,0,0); // TODO: generate, fix with mul( vpos?, cameraToClip ) ??
Current.position        = hpos;
Current.texcoord<t0>    = float4( toViewFarClip, 0 );
Current.texcoord<t1>    = float4( deferredLight.diffColor.rgb, 1 ) * level;
Current.texcoord<t2>    = float4( p0, radius2 );
Current.texcoord<t3>    = float4( p1, innerRadius2 );
Current.texcoord<t4>    = float4( -denom, + innerRadius2 * -denom + 1, screenUV );
Current.texcoord<t5>    = float4( rayNormal, rayLen2 );
