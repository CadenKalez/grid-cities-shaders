// Shader fragment  [VS slot 115]  effectToWorldVF

// ---- uniform parameters ----
uniform float4x3 modelToWorld;   // reg-meta 000800080003000000000001

// ---- fragment body (spliced into the generated main()) ----
float4 worldPos;
{
worldPos = mul( float4( quadPos, 1 ), modelToWorld );
}
