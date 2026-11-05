// Shader fragment  [VS slot 121]  effectBlackCrushAnimOutputVF

// ---- fragment body (spliced into the generated main()) ----
Current.position            = clipPos;
Current.color               = color;
Current.texcoord<t0>        = float4( uv.x, tileUV.x, uv.x, tileUV.y );
Current.texcoord<t1>.x      = tileBlend;
Current.texcoord<t1>.y      = 0.0;
Current.texcoord<t1>.z      = blackPoint;
Current.texcoord<t1>.w		= midPoint;
