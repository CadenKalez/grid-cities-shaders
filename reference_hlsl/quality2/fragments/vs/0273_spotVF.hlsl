// Shader fragment  [VS slot 273]  spotVF

// ---- uniform parameters ----
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float farClip           = cameraParams[2].y;
float nearClip          = cameraParams[2].x + 0.01;
float4 dlColor          = deferredLight.diffColor;
float4 pos              = float4( modelPosition.xyz, 1 );
float3 vertexWorldPos   = mul (pos, modelToWorld).xyz;
float4 vpos             = float4( mul( pos, modelToCamera ), 1 );
vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
float4 hpos             = mul( vpos, cameraToClip );
float3 crwpLightPos     = modelToWorld[3] - worldCameraPosition.xyz;
float3 ldir             = normalize( modelToWorld[2].xyz );
float3 crwpFarClip      = vpos.xyz * farClip;
crwpFarClip             = mul( crwpFarClip, make_float3x3(cameraToWorld) );
float Kd                = deferredLight.params.x;
float Ks                = deferredLight.params.y;
float falloffStart      = deferredLight.params.z;
float falloffDist       = deferredLight.params.w;
// These are actually the cos of the angle
float innerRadius       = deferredLight.endPosition.w;
float radius            = deferredLight.position.w;
float volStrength       = deferredLight.endPosition.x;
float doubleSided       = deferredLight.endPosition.y;
