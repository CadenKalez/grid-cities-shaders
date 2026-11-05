// Shader fragment  [VS slot 281]  lineVF

// ---- uniform parameters ----
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4 deferredInfo;   // reg-meta 02ad02ad0001000000000008
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000

// ---- fragment body (spliced into the generated main()) ----
float farClip           = cameraParams[2].y;
float nearClip          = cameraParams[2].x + 0.01;

float4  pos             = float4( modelPosition.xyz, 1 );


        float3  vertexWorldPos  = mul(pos, modelToWorld);
        float4  vpos            = float4( mul( pos, modelToCamera ), 1 );
vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
float4 hpos             = mul( vpos, cameraToClip );
float3 crwp             = vpos.xyz * farClip;
crwp                    = mul( crwp, make_float3x3(cameraToWorld) );
float3  p0              = deferredLight.position.xyz;
float3  p1              = deferredLight.endPosition.xyz;
float   radius          = deferredLight.position.w;
float   radius2         = radius * radius;
float   innerRadius     = deferredLight.endPosition.w;
float   innerRadius2    = innerRadius * innerRadius;
float   Kd              = deferredLight.params.x;
float   Ks              = deferredLight.params.y;
float   volStrength     = deferredLight.params.z;
float   doubleSided     = deferredLight.params.w;
