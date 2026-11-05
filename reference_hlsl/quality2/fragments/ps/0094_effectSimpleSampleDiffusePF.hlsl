// Shader fragment  [PS slot 94]  effectSimpleSampleDiffusePF

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 diffuse     = (lerp(tex2D(map, uvTile1), tex2D(map, uvTile2), frameDelta)) ;
