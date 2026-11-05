// Shader fragment  [PS slot 495]  rgbBltCubePF

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
// identity texture:
//Current.color       = float4(In.texcoord0.x, 1-frac(In.texcoord0.y * 32.0f), 1-(floor(In.texcoord0.y*32))/32, 1.0f);
Current.color       = tex2D( map, In.texcoord0 );
