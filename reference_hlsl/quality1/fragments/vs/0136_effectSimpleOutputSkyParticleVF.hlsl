// Shader fragment  [VS slot 136]  effectSimpleOutputSkyParticleVF

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4 cameraParams[3];   // reg-meta 022202220003000000004000

// ---- fragment body (spliced into the generated main()) ----
Current.position            = mul( float4( modelPosition.xyz, 1 ), modelToClip ); 
Current.color               = color;
Current.texcoord<t0>        = float4( uvTile1.xy, uvTile2.xy );
Current.texcoord<t1>        = float4( frameDelta, 0, blackPoint, midPoint );
Current.texcoord<t2>        = Current.position;
