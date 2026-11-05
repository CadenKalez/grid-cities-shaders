// Shader fragment  [VS slot 119]  effectBlackCrushOutputVF

// ---- fragment body (spliced into the generated main()) ----
Current.position            = clipPos;
Current.color               = color;
Current.texcoord<t0>.xy     = uv;
Current.texcoord<t0>.z      = blackPoint;
Current.texcoord<t0>.w		= midPoint;
