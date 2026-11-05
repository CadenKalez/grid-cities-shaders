// Shader fragment  [PS slot 512]  temporalAAPS

// ---- declarations / helper functions ----
extern uniform sampler prevFrameTexture : register(s2);

// ---- fragment body (spliced into the generated main()) ----
float kCamMoveDistanceFactor = 100.0;
float kBlendFactor = .5; 
float4 pixelCurrent = tex2D(colorTexture, screenUV);  
float4 pixelPrev = tex2D(prevFrameTexture, screenUV);
float colError = max(pixelCurrent.a, pixelPrev.a);
float camMoveFactor = length(prevUV - screenUV) * kCamMoveDistanceFactor; // maybe use dist^2 here?
float ssaaBlendFactor = saturate(max(camMoveFactor, colError));
float4 ssaa = lerp(pixelCurrent, pixelPrev, kBlendFactor);
float4 blurResult = lerp(ssaa, blurred, ssaaBlendFactor);
Current.color = blurResult;
