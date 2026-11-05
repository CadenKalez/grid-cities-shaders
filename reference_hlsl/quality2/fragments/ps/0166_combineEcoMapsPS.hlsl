// Shader fragment  [PS slot 166]  combineEcoMapsPS

// ---- declarations / helper functions ----
extern uniform sampler Map1 : register(s0);
extern uniform sampler Map2 : register(s1);
extern uniform sampler Map3 : register(s2);
extern uniform sampler Map4 : register(s3);
extern uniform sampler controlMap : register(s4);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = float2(In.texcoord0.xy);
float v1 = tex2D(Map1, uv).x;  
float v2 = tex2D(Map2, uv).x;  
float v3 = tex2D(Map3, uv).x;  
float v4 = tex2D(Map4, uv).x;  
float4 controlChannels = tex2D(controlMap, uv).rgba;
float mask = any(controlChannels.a);
v2 = saturate(v2 - mask);
Current.color.rgba = float4(v1, v2, v3, v4);
