// Shader fragment  [PS slot 104]  networkRoadBasicMaterialSetup

// ---- declarations / helper functions ----
sampler2D diffuseSampler        : register(s0);
sampler2D normalMapSampler      : register(s1);
sampler2D specSampler           : register(s2);
sampler2D noiseMaskSampler      : register(s3);

// ---- fragment body (spliced into the generated main()) ----
float2 baseUV        = In.texcoord<t0>.xy;
float3 tileUV        = In.texcoord<t1>.xyz;
float3 worldPosition = In.texcoord<t2>.xyz;
float3 worldTangent  = In.texcoord<t3>.xyz;
