// Shader fragment  [VS slot 274]  spotVFInstanced

// ---- uniform parameters ----
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float farClip           = cameraParams[2].y;
float nearClip          = cameraParams[2].x + 0.01;
float4 dlColor      = In.texcoord0;
float4 dlParams     = In.texcoord1;
float4 dlPos        = In.texcoord2;
float4 dlEndPos     = In.texcoord3;
float4 pos              = float4( modelPosition.xyz, 1 );
float4x4 dlTransform    = float4x4(In.texcoord4, In.texcoord5, In.texcoord6, In.texcoord7);
float4 vpos             = mul( pos, dlTransform );
float3 vertexWorldPos   = vpos.xyz;
vpos                    = float4( mul( vpos, worldToCamera ).xyz, 1 );
vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
float4 hpos             = mul( vpos, cameraToClip );
float3 crwpLightPos     = dlPos.xyz - worldCameraPosition.xyz;
float3 ldir             = normalize( In.texcoord6.xyz );
float3 crwpFarClip      = vpos.xyz * farClip;
crwpFarClip             = mul( crwpFarClip, make_float3x3(cameraToWorld) );
float Kd                = dlParams.x;
float Ks                = dlParams.y;
float falloffStart      = dlParams.z;
float falloffDist       = dlParams.w;
// These are actually the cos of the angle
float innerRadius       = dlEndPos.w;
float radius            = dlPos.w;
float volStrength       = dlEndPos.x;
float doubleSided       = dlEndPos.y;
