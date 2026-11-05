// Shader fragment  [VS slot 269]  debugPointVF

// ---- uniform parameters ----
uniform struct { float4 diffColor; float4 params; float4 position; float4 endPosition; } deferredLight;   // reg-meta 02aa02aa0004000000000008
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 pos              = float4( modelPosition.xyz * deferredLight.position.w + deferredLight.position.xyz, 1 );
float4 hpos             = mul( pos, worldToClip );
Current.position        = hpos;
Current.color           = float4( deferredLight.diffColor.rgb, 1 );
