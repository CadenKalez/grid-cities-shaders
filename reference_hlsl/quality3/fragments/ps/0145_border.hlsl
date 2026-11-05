// Shader fragment  [PS slot 145]  border

// ---- fragment body (spliced into the generated main()) ----
const float kEdge = 0.1f;
float minUV = min(uv.x,uv.y);
float minAlpha = smoothstep(kEdge, 0, minUV);
float maxUV = max(uv.x,uv.y);
float maxAlpha = smoothstep(1 - kEdge, 1, maxUV);
Current.color = color;
Current.color.a *= max(minAlpha,maxAlpha);
