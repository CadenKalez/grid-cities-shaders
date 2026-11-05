// Shader fragment  [VS slot 118]  effectToDepthOffsetClipVF

// ---- uniform parameters ----
uniform float4x4 worldToClip;   // reg-meta 000c000c0004000000004000
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float4 clipPos;
{
float depthBias = customParams[1].w;
clipPos = mul( float4( quadPos, 1 ), worldToClip );
float4 depthOffset = float4( 0, 0, depthBias / clipPos.w, 0 );
clipPos.xyz += depthOffset;
}
