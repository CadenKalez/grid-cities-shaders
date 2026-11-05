// Shader fragment  [PS slot 82]  effectSampleDiffusePS

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 diffuse		= tex2D( map, uv ) * color;
