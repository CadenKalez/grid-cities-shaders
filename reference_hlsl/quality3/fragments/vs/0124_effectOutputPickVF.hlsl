// Shader fragment  [VS slot 124]  effectOutputPickVF

// ---- fragment body (spliced into the generated main()) ----
Current.position            = clipPos;
Current.color               = color;
Current.texcoord<t0>.xy     = float2( uv.x, tileUV.x );
Current.texcoord<t0>.zw     = 0.0;
