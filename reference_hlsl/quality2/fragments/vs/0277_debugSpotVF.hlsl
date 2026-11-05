// Shader fragment  [VS slot 277]  debugSpotVF

// ---- uniform parameters ----
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- fragment body (spliced into the generated main()) ----
float4 pos              = float4( modelPosition.xyz * 1.05, 1 );
float4 hpos             = mul( pos, modelToClip );
Current.position        = hpos;
Current.color           = float4( deferredLight.diffColor.rgb, 1 );
