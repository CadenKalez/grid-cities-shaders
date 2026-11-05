// Shader fragment  [VS slot 262]  stencilToClip

// ---- uniform parameters ----
uniform float4 shadowFrustumInfo;   // reg-meta 02c302c30001000000000008
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 pos              = float4( modelPosition.xyz, 1 );
pos.z = shadowFrustumInfo.z;
float4 hpos             = mul( pos, cameraToClip );
hpos.xy = modelPosition.xy * hpos.w;
Current.position        = hpos;
