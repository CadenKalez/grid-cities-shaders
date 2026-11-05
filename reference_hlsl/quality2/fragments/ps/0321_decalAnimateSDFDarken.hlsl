// Shader fragment  [PS slot 321]  decalAnimateSDFDarken

// ---- fragment body (spliced into the generated main()) ----
float materialTubeLightFactor = decalMaterialInfo.z * 8 + 1;
float4 lightFactor = lesser_than(animResults, 0) ? float4(materialTubeLightFactor, materialTubeLightFactor, materialTubeLightFactor, materialTubeLightFactor) : float4(0.1, 0.1, 0.1, 0.1);
float4 powerFactor = lerp(float4(0.5, 0.5, 0.5, 0.5), lightFactor, decalMaterialInfo.wwww);
decalMaterialData[0] *= powerFactor;
decalMaterialData[1] *= powerFactor;
decalMaterialData[2] *= powerFactor;
/*
decalMaterialData[0].rgb *= powerFactor.x;
decalMaterialData[1].rgb *= powerFactor.y;
decalMaterialData[2].rgb *= powerFactor.z;
decalMaterialData[3].rgb *= powerFactor.w;
*/
