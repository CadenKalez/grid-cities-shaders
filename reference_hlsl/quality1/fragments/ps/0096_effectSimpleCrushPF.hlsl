// Shader fragment  [PS slot 96]  effectSimpleCrushPF

// ---- uniform parameters ----
uniform float4 customParams[2];   // reg-meta 020602060002000000000008

// ---- fragment body (spliced into the generated main()) ----
float crushAlpha = customParams[0].x;
float crushRGB   = customParams[0].y;
if ( crushAlpha != 0 )
{
float4 crush = float4(0, 0, 0, 0);
if ( diffuse.a < midPoint )
crush += midPoint * ( diffuse - blackPoint ) / ( midPoint - blackPoint + 0.0001 );
else
crush += diffuse;
diffuse.rgb     = lerp(diffuse.rgb, crush.rgb, crushRGB);
diffuse.a       = lerp(diffuse.a, crush.a, crushAlpha);
}
