// Shader fragment  [VS slot 114]  effectToClipVF

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001

// ---- fragment body (spliced into the generated main()) ----
float4 clipPos;
{
clipPos = mul( float4( quadPos, 1 ), modelToClip );
}
