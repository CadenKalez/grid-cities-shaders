// Shader fragment  [PS slot 22]  shShowNormal

// ---- fragment body (spliced into the generated main()) ----
float3 vertNormal = In.texcoord<t0>.xyz;
Current.color.rgb = 0.5 * vertNormal.xyz + 0.5;
