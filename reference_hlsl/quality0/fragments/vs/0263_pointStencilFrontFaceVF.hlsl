// Shader fragment  [VS slot 263]  pointStencilFrontFaceVF

// ---- uniform parameters ----
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000

// ---- fragment body (spliced into the generated main()) ----
float nearClip          = cameraParams[2].x + 0.01;
float4 pos              = float4( modelPosition.xyz * deferredLight.position.w + deferredLight.position.xyz, 1 );
float4 vpos             = float4( mul( pos, worldToCamera ), 1 );
vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
float4 hpos             = mul( vpos, cameraToClip );
Current.position        = hpos;
