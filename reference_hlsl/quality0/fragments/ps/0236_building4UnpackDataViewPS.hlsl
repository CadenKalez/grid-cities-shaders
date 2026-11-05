// Shader fragment  [PS slot 236]  building4UnpackDataViewPS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float4 regionXform = In.texcoord<t1>;
float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
float3 worldNormal = In.texcoord<t2>.xyz;
