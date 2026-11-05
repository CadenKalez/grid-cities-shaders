// Shader fragment  [PS slot 455]  renderAlphaPS

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
        half4 diffuse       = tex2D( map, In.texcoord0 );

Current.color.rgba  = float4(diffuse.aaa, 1);
