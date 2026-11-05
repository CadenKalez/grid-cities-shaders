// Shader fragment  [VS slot 272]  spotQuadVF

// ---- uniform parameters ----
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4 viewFarCorners[4];   // reg-meta 02a902a90004000000000008

// ---- fragment body (spliced into the generated main()) ----
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
