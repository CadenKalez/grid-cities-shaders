// Shader fragment  [PS slot 451]  renderRedPS

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
half4 diffuse       = tex2D( map, In.texcoord0 );
diffuse.x = (diffuse.x*256.f + diffuse.y)/256.f;
Current.color.rgba  = float4(diffuse.xxx, 1);
