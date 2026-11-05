// Shader fragment  [PS slot 433]  spotSpecPF

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float3 toCamera = normalize( worldCameraPosition.xyz - pos.xyz );
float3 h = normalize( lightDirNormal + toCamera );
float ndoth = saturate( dot( normal.xyz, h ) );
float spec = pow( ndoth, specPow );
Current.color.a = diffLightColor.a * totalAtten * spec * gloss;
