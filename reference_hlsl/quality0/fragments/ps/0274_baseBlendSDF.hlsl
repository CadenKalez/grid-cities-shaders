// Shader fragment  [PS slot 274]  baseBlendSDF

// ---- declarations / helper functions ----
float4 baseGetAlpha(float4 pixelRGBA, float2 texCoord, float blurWidth, float maskCenter)
{
float4 width = fwidth(pixelRGBA.rgba);  //abs(ddx(texCoord)) + abs(ddy(texCoord));
float4 lineEdge = blurWidth*width*1.5;
return smoothstep(max(maskCenter-lineEdge,0.05f),min(maskCenter+lineEdge,0.95f),pixelRGBA);
}

// ---- fragment body (spliced into the generated main()) ----

