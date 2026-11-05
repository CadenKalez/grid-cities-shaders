// Shader fragment  [PS slot 501]  calcLumaPS

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float3 diffuse      = tex2D( map, In.texcoord0.xy ).rgb;
Current.color.rgba  = float4(diffuse, sqrt(dot(diffuse, float3(0.2126, 0.7152, 0.0722))));
