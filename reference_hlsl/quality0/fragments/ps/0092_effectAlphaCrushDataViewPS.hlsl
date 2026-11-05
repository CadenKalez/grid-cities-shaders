// Shader fragment  [PS slot 92]  effectAlphaCrushDataViewPS

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
float4 crush = float4(0, 0, 0, 0);
if ( diffuse.a < midPoint )
crush += midPoint * ( diffuse - blackPoint ) / ( midPoint - blackPoint + 0.0001 );
else
crush += diffuse;
Current.color.rgb   = (globalDataView.baseColor.rgb + (diffuse.r+diffuse.g+diffuse.b));
Current.color.a		= crush.a;
