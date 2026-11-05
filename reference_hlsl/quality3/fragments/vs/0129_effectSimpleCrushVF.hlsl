// Shader fragment  [VS slot 129]  effectSimpleCrushVF

// ---- uniform parameters ----
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float blackPoint;
float midPoint;
float fadeRate = customParams[0].w;
blackPoint = 0.0f;
if ( fadeRate > 1.f )
{
blackPoint = saturate( 1-age * (fadeRate - 1) );
}
else
{
blackPoint = saturate( age * fadeRate );
}
midPoint = ( 1.0 + blackPoint ) * 0.5;
