// Shader fragment  [PS slot 89]  effectBlackCrushPS

// ---- fragment body (spliced into the generated main()) ----
float4 crush = float4(0, 0, 0, 0);
if ( diffuse.a < midPoint )
crush += midPoint * ( diffuse - blackPoint ) / ( midPoint - blackPoint + 0.0001 );
else
crush += diffuse;
Current.color.rgb   = crush.rgb;
Current.color.a		= crush.a;
