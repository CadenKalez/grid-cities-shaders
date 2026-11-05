// Shader fragment  [PS slot 287]  textureLotOverlayCombine

// ---- fragment body (spliced into the generated main()) ----
lotTexMask = float4(0, 0, 0, 0);
addOverlay(overlayTexMask, overlayUntransformedTexCoord, 1.0, 0.5f, lotTexMask, overlayMask,
In.texcoord1, In.texcoord2, In.texcoord3,
In.texcoord4, In.texcoord5, In.texcoord6,
In.color); // first value, width of lines (for anti-aliasing). second value, test threshold.
gloss = 0.06;
//clip(lotTexMask.a-(0.5/255.0));
Current.color.rgba = lotTexMask.rgba;
//Current.color.rgba = float4(overlayTexCoord.xy,0,1);
//Current.color.rgba = float4(0,0,0,1);
