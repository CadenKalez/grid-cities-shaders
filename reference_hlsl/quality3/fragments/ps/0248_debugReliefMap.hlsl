// Shader fragment  [PS slot 248]  debugReliefMap

// ---- declarations / helper functions ----
sampler2D diffuseSampler        : register(s0);
sampler2D normalSampler         : register(s1);
sampler2D shaderSampler         : register(s2);

// ---- fragment body (spliced into the generated main()) ----
float4 diffuseTex = tex2D(diffuseSampler, In.texcoord<t0>.xy);
Current.color.rgba = float4(diffuseTex.xyz + diffuseTex.www, 1);
float4 normalTex = tex2D(normalSampler, In.texcoord<t0>.xy);
float3 normal = normalTex.xyz * 2 - 1;
float3 lightDir = normalize(float3(0.4,0.4,1));
float light = saturate(dot(normal, lightDir)) * 0.8 + 0.2;
Current.color.rgb *= saturate(light);
