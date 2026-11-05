// Shader fragment  [PS slot 140]  zoomFade

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
float zoomBlend = globalDataView.fadeInfo.y * color.a;
Current.color = float4(color.r, color.g, color.b, zoomBlend);
