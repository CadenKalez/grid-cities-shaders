// Shader fragment  [PS slot 54]  MovieThresholdPS_1

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008

// ---- samplers ----
sampler movie;

// ---- fragment body (spliced into the generated main()) ----
const float kLevels = (1);
float4 halfSI = screenInfo * 0.5;  // tap width
float4 sc0 = tex2D(movie, In.texcoord0.xy + float2(halfSI.z, 0));
float4 sc1 = tex2D(movie, In.texcoord0.xy - float2(halfSI.z, 0));
float4 sc2 = tex2D(movie, In.texcoord0.xy + float2(0, halfSI.w));
float4 sc3 = tex2D(movie, In.texcoord0.xy - float2(0, halfSI.z));
Current.color = 0.25 * (sc0 + sc1 + sc2 + sc3) * Current.color;
float lum = (1 / kLevels) * round(kLevels * Current.color.g);
Current.color.rgb = float3(lum, lum, lum);
