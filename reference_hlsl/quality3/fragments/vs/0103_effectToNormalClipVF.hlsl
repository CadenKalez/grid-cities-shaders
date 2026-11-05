// Shader fragment  [VS slot 103]  effectToNormalClipVF

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- fragment body (spliced into the generated main()) ----
float4 clipPos;
{
clipPos = mul( float4( modelPosition.xyz, 1 ), modelToClip );
clipPos.xyz /= clipPos.w;
clipPos.w = 1;
}
