// Shader fragment  [VS slot 278]  lineStencilFrontFaceVF

// ---- uniform parameters ----
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000

// ---- fragment body (spliced into the generated main()) ----
float nearClip          = cameraParams[2].x + 0.01;
float4  pos             = float4( modelPosition.xyz, 1 );
float4  vpos            = float4( mul( pos, modelToCamera ), 1 );
vpos.z                  = vpos.z < nearClip ? nearClip : vpos.z;
float4 hpos             = mul( vpos, cameraToClip );
Current.position        = hpos;
