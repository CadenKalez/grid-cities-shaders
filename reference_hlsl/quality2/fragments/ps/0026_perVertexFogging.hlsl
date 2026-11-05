// Shader fragment  [PS slot 26]  perVertexFogging

// ---- uniform parameters ----
uniform float4 foggingCPU;   // reg-meta 022502250001000000004009

// ---- declarations / helper functions ----
extern uniform sampler scatterMap : register(s9);

// ---- fragment body (spliced into the generated main()) ----
float fogStrength = In.texcoord<t0>.w;
float4 scatterColor  = texCUBE( scatterMap, In.texcoord<t0>.xyz );
Current.color.rgb = lerp( Current.color.rgb, scatterColor.rgb, fogStrength ) + scatterColor.rgb * scatterColor.a * foggingCPU.w;
