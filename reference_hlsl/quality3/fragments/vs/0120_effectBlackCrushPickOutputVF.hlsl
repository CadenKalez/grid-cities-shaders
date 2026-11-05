// Shader fragment  [VS slot 120]  effectBlackCrushPickOutputVF

// ---- fragment body (spliced into the generated main()) ----
Current.position            = clipPos;
Current.color               = color;
Current.texcoord<t0>.xy     = float2( uv.x, tileUV.x );
Current.texcoord<t0>.z      = blackPoint;
Current.texcoord<t0>.w		= midPoint;
