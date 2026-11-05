// Shader fragment  [VS slot 116]  effectToViewVF

// ---- uniform parameters ----
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001

// ---- fragment body (spliced into the generated main()) ----
float3 viewPos;
{
viewPos = mul( float4( quadPos, 1 ), modelToCamera );
}
