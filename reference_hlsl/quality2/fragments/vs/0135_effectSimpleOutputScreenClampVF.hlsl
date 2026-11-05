// Shader fragment  [VS slot 135]  effectSimpleOutputScreenClampVF

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float clampScreenSizeMin = customParams[1].z;
float clampScreenSizeMax = customParams[1].w;
// This is far from optimal. At some point this calculation (sxyz) needs to be
// done in the runtime and passed int via constant.
// Find the scale factors for x' and y'
float sx2  = dot( worldToClip[0], worldToClip[0] );
float sy2  = dot( worldToClip[1], worldToClip[1] );
float sz2  = dot( worldToClip[2], worldToClip[2] );
float sxyz = sqrt( sx2 + sy2 + sz2 );
// Find w'
float sw;
sw = worldToClip[0].w * modelPosition.x +
worldToClip[1].w * modelPosition.y +
worldToClip[2].w * modelPosition.z +
worldToClip[3].w;
float relSize = 10.0f * sxyz / sw; // 10 is just to nudge into a "sensible" range around 1.
float clampedRelSize = clamp( relSize, clampScreenSizeMin, clampScreenSizeMax );
float scale = ( sw > 0.0f ) ? ( clampedRelSize / relSize ) : 1.0f;
position += ( ( up  + across ) * scale );
float4 clipPosition = mul( float4( position, 1 ), modelToClip );
Current.position            = clipPosition; 
Current.color               = color;
Current.texcoord<t0>        = float4( uvTile1.xy, uvTile2.xy );
Current.texcoord<t1>        = float4( frameDelta, 0, 0, 0 );
Current.texcoord<t2>        = Current.position;
