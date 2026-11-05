// Shader fragment  [PS slot 324]  decalOpacity

// ---- fragment body (spliced into the generated main()) ----
// Relies on float4 decalMaterialInfo
Current.color.a *= decalMaterialInfo.x;
