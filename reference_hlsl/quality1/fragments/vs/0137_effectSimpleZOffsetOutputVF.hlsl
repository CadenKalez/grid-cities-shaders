// Shader fragment  [VS slot 137]  effectSimpleZOffsetOutputVF

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001
uniform float4x4 cameraToClip;   // reg-meta 001200120004000000004000
uniform float4 nearFar;   // reg-meta 002e002e00010000000ffffd

// ---- fragment body (spliced into the generated main()) ----
float3 viewPos;
viewPos = mul( float4( modelPosition.xyz, 1 ), modelToCamera );
//HACK, do not allow vertices to exceed far clip plane
if ( viewPos.z > nearFar.y )
{
viewPos.z=nearFar.y - 5.0f; 
}
Current.position            = mul( float4( viewPos.xyz, 1 ), cameraToClip ); 
Current.color               = color;
Current.texcoord<t0>        = float4( uvTile1.xy, uvTile2.xy );
Current.texcoord<t1>        = float4( frameDelta, 0, blackPoint, midPoint );
Current.texcoord<t2>        = Current.position;
