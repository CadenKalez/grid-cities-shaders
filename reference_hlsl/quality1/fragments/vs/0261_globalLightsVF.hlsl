// Shader fragment  [VS slot 261]  globalLightsVF

// ---- uniform parameters ----
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4 gameInfo;   // reg-meta 024802480001000000000008
uniform float4 worldFarCorners[4];   // reg-meta 02b602b60004000000000008

// ---- fragment body (spliced into the generated main()) ----
float2 pos              = modelPosition.xy;
int i                   = int(modelPosition.z);
float   time            = gameInfo.x;
float2 screenUV         = pos.xy * deferredInfo.xy + deferredInfo.zw;
float denom             = 1.0 / ( end - start );
float4 param            = float4( denom, -start * denom, alpha, 1 - alpha );
param.xy *= param.xy;
Current.position        = float4( pos.xy, 0, 1 );
Current.texcoord<t0>    = float4( screenUV, 0, 0 );
Current.texcoord<t1>    = float4( pos.xy, 0, 1 );
Current.texcoord<t2>    = param;
Current.texcoord<t3>    = worldFarCorners[i];
