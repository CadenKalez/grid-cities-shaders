// Shader fragment  [VS slot 221]  decalMaterialInfoWithObjectData

// ---- uniform parameters ----
uniform float4 customParams[16];   // reg-meta 020602060010000000000008

// ---- fragment body (spliced into the generated main()) ----
int realXformIdx = xformIdx / 3; // Why did I premultiply these again?  So silly.
int customParamIndex = realXformIdx / 4;
int customParamCpt = realXformIdx % 4;
Current.texcoord<t0>.xyz = Current.indices.yzw * (1.0 / 255.0);
Current.texcoord<t0>.w = customParams[customParamIndex][customParamCpt];
