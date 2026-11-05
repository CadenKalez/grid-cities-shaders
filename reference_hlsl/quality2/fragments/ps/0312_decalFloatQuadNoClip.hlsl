// Shader fragment  [PS slot 312]  decalFloatQuadNoClip

// ---- fragment body (spliced into the generated main()) ----
float3 textureFloatPosition = In.texcoord<t0>.xyz;
float2 uvOrig = textureFloatPosition.xy * -0.5 + 0.5;
float2 uv = uvOrig * texXform.xy + texXform.zw;
float4 decalTexture = tex2D(Sampler<s0>, uv);
Current.color = decalTexture;
//Current.color.a = 1;
