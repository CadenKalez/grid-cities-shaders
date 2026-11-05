// Shader fragment  [PS slot 139]  copyDataViewColor

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
Current.color = float4(globalDataView.baseColor.rgb, 1);
