// Shader fragment  [PS slot 65]  particleQuadUnifiedPS

// ---- samplers ----
sampler diffuse;

// ---- fragment body (spliced into the generated main()) ----
float4 tileColor0 = tex2D(diffuse, Current.texcoord0);
float4 tileColor1 = tex2D(diffuse, Current.texcoord1);
fragOut.color *= lerp(tileColor0, tileColor1, Current.color1.y);
