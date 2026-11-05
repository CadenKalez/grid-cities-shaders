// Shader fragment  [PS slot 442]  lineSpecPF

// ---- fragment body (spliced into the generated main()) ----
float3 npos = normalize( pos.xyz );
float3 h = normalize( lightDirNormal - npos );
float ndoth = saturate( dot( normal.xyz, h ) );
float spec = pow( ndoth, specPow );
Current.color.a = finalLightSpec * spec * gloss;
