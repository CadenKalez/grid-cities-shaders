// Shader fragment  [PS slot 276]  applyEdge

// ---- declarations / helper functions ----
float calculateEdge(float4 texCoord, float4 tangent, float edgeWidth)
{
float minMin = min(min(texCoord.x,texCoord.y),texCoord.z);
minMin = min(min(min(tangent.x,tangent.y),tangent.z),minMin);
float width = saturate(fwidth(minMin) + 0.5);
//return smoothstep(edgeWidth+width,edgeWidth-width,minMin);
return smoothstep(10,-10,minMin);
//return step(minMin,edgeWidth);
}

// ---- fragment body (spliced into the generated main()) ----
const float MIN_STROKE = 0.9f;
const float MAX_STROKE = 1.3f;
// Relies on the fact that the hover lot has an alpha of 1
float edgeMult = 1.f;
if (vertAlpha > 0.95f)
{
edgeMult = 2.f;
vertAlpha = 0.1;
}
float edgeAlpha = calculateEdge(texCoord, tangent, edgeMult * clamp(camDistance/600.f, MIN_STROKE, MAX_STROKE));
//Current.color.a = 1.0-edgeAlpha;
