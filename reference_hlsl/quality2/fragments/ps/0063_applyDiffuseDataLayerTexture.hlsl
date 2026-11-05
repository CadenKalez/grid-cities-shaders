// Shader fragment  [PS slot 63]  applyDiffuseDataLayerTexture

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.color.rgb = (Current.color.r + Current.color.g + Current.color.b) + globalDataView.baseColor.rgb;
