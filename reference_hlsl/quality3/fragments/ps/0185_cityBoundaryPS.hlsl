// Shader fragment  [PS slot 185]  cityBoundaryPS

// ---- uniform parameters ----
uniform float4 customParams[4];   // reg-meta 020602060004000000000008

// ---- declarations / helper functions ----
sampler textureSampler : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float4 texColor = tex2D(textureSampler, In.texcoord0.xy);
// Adjust opacity
Current.color = In.color * texColor * customParams[0].x;
Current.color.a = texColor.a * customParams[0].x;
