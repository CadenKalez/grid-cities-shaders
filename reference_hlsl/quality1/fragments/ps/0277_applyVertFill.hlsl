// Shader fragment  [PS slot 277]  applyVertFill

// ---- uniform parameters ----
uniform float4 zoneFill;   // reg-meta 02d302d30001000000000008

// ---- fragment body (spliced into the generated main()) ----
// This is set by the data layer system. Normally it is 1.0f
float zoneAlpha = zoneFill.x;//1.0 + (1.0-zoneFill.x);
float cameraFadeInDist = zoneFill.y;
float cameraFadeOutDist = zoneFill.z;
float camFade = saturate((camDistance - cameraFadeOutDist) / (cameraFadeInDist - cameraFadeOutDist));
Current.color.a = saturate((zoneAlpha * vertAlpha * camFade)-edgeAlpha);
