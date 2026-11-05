// Shader fragment  [PS slot 142]  occludeFadePost

// ---- uniform parameters ----
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;   // reg-meta 02c602c60002000000000008

// ---- fragment body (spliced into the generated main()) ----
float occlusionBlend = globalDataView.fadeInfo.x * Current.color.a;
Current.color = float4(Current.color.r, Current.color.g, Current.color.b, occlusionBlend);
