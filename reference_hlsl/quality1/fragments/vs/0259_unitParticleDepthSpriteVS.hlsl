// Shader fragment  [VS slot 259]  unitParticleDepthSpriteVS

// ---- fragment body (spliced into the generated main()) ----
// Per-pixel depth for sprite.
float2 reconstructDepth = mul( float4( 0.0f, 0.0f, cardDepth.y, 0.0f ), cameraToClip ).zw;
Current.texcoord<t0> = float4( cameraAlignedClipPos.zw, reconstructDepth );
