// Shader fragment  [PS slot 73]  distCameraFacingQuadZPoleWave_PS

// ---- samplers ----
sampler sourceTex;

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(sourceTex, In.texcoord0);
Current.color = In.color * texColor;
