// Shader fragment  [PS slot 114]  rwRoadShaderDefaultPS

// ---- declarations / helper functions ----
sampler2D diffuseSampler        : register(s0);
sampler2D normalMapSampler      : register(s1);
sampler2D specSampler           : register(s2);

// ---- fragment body (spliced into the generated main()) ----
float2 baseUV = In.texcoord<t0>.xy;
float3 vertDS = In.texcoord<t1>.xyz;
float4 v4Diffuse = tex2D( diffuseSampler, baseUV );
clip( v4Diffuse.a - 0.75f ); // we're using alpha test but not actually outputing the alpha so it works better on deferred renderer. Otherwise the transparency could cause issues
Current.color.rgb = v4Diffuse.rgb;
Current.color.a   = 1.0f;
