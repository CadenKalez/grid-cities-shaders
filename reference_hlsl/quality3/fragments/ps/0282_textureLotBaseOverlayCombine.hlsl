// Shader fragment  [PS slot 282]  textureLotBaseOverlayCombine

// ---- fragment body (spliced into the generated main()) ----
addOverlay(overlayTexMask, overlayUntransformedTexCoord, 1.0, 0.5f, lotTexMask, overlayMask,
In.texcoord1, In.texcoord2, In.texcoord3,
In.texcoord4, In.texcoord5, In.texcoord6,
In.color); // first value, width of lines (for anti-aliasing). second value, test threshold.
gloss = 0.06;
Current.color.rgba = lotTexMask.rgba;
