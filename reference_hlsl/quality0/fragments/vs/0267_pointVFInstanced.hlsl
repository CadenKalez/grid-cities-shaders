// Shader fragment  [VS slot 267]  pointVFInstanced

// ---- uniform parameters ----
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float nearClip          = cameraParams[2].x + 0.01;
float farClip           = cameraParams[2].y;
float4 dlPos = In.texcoord2;
float4 dlParams = In.texcoord1;
float4 dlEndPos = In.texcoord3;
float4 dlColor = In.texcoord0;
float4 pos              = float4( modelPosition.xyz * dlPos.w + dlPos.xyz, 1 );
float4 vpos             = float4( mul( pos, worldToCamera ), 1 );
vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
float4 hpos             = mul( vpos, cameraToClip );
float3 crwpLightPos     = dlPos.xyz - worldCameraPosition.xyz;
float3 crwpFarClip      = vpos.xyz * farClip;
crwpFarClip             = mul( crwpFarClip, make_float3x3(cameraToWorld) );
crwpFarClip             /= vpos.z;
float Kd                = dlParams.x;
float Ks                = dlParams.y;
float radius            = dlPos.w;
float innerRadius       = dlEndPos.w;
float volStrength       = dlEndPos.x;
float doubleSided       = dlEndPos.y;
float radiusSqr         = radius * radius;
float denom             = 1.0 / ( radiusSqr - innerRadius*innerRadius );
// Final attenuation calculation is:
// (radius - radiusAtPixel) / (radius - innerRadius)
float4 level            = float4( Kd, Kd, Kd, Ks );
Current.position        = hpos;
Current.texcoord<t0>    = float4( hpos.xy * deferredInfo.xy + deferredInfo.zw * hpos.w, denom, hpos.w );
Current.texcoord<t1>    = float4( dlColor.rgb, 1.0 ) * level;
Current.texcoord<t2>    = float4( crwpFarClip.xyz * hpos.w, volStrength );
Current.texcoord<t3>    = float4( crwpLightPos, radiusSqr * denom );
Current.texcoord<t4>    = float4( pos.xy, 0, 0 ); //.zw used by volumetric lighting
Current.texcoord<t5>    = float4( doubleSided, 0, 0, 0 );
