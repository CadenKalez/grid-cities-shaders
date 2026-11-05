// Shader fragment  [PS slot 101]  effectSimpleDataviewPF

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
diffuse.rgb   = (globalDataView.baseColor.rgb + (diffuse.r + diffuse.g + diffuse.b));
