// Shader fragment  [PS slot 234]  building4UnpackDeferredPS

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float2 uv2 = In.texcoord<t0>.zw;
float3 eyeDir = In.texcoord<t1>.xyz;
float outputDepth = In.texcoord<t1>.w;
float4 regionXform = In.texcoord<t2>;
float4 regionXform2 = In.texcoord<t3>;
float3 worldNormal = In.texcoord<t4>.xyz;
float3 worldTangent = In.texcoord<t5>.xyz;
float2 tilePadding = float2(In.texcoord<t4>.w, In.texcoord<t5>.w);
