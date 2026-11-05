// Shader fragment  [PS slot 141]  occludeFade

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
float occlusionBlend = globalDataView.fadeInfo.x * color.a;
color = float4(color.r, color.g, color.b, occlusionBlend);
