// Shader fragment  [PS slot 352]  impostorTreeShadowPS

// ---- fragment body (spliced into the generated main()) ----
float3 clipPosition = In.texcoord<t1>.xyz;              
clip(float4(1 + clipPosition.xy, 1 - clipPosition.xy));
float2 uv0 = In.texcoord<t0>.xy;
float2 uv1 = In.texcoord<t0>.zw;
float leavesFallen = In.texcoord<t1>.w;
float4 diffuseMap = tex2D(Sampler<s0>, uv0);
float4 normalMap  = tex2D(Sampler<s1>, uv0);
float4 aoMap      = tex2D(Sampler<s2>, uv1);
float alpha = step(0.6, diffuseMap.a * saturate(100 * (aoMap.a - leavesFallen) + 1));
float depth = clipPosition.z;
Current.color = float4(0.0f, 0.0f, depth, alpha);
