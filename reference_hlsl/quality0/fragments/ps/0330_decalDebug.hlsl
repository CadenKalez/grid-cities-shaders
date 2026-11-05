// Shader fragment  [PS slot 330]  decalDebug

// ---- fragment body (spliced into the generated main()) ----
float3 outsideV = 1 - abs(texturePosition);
bool outside = outsideV.x < 0 || outsideV.y < 0 || outsideV.z < 0;
Current.color = float4(frac(texturePosition.xy * -0.5 + 0.5), outside ? 1 : 0, 1);
