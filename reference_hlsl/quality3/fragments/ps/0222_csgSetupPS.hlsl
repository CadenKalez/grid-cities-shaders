// Shader fragment  [PS slot 222]  csgSetupPS

// ---- declarations / helper functions ----
extern uniform sampler P1 : register(s0);  
extern uniform sampler P2 : register(s1);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = float2(In.texcoord<t0>.xy);
float p1 = tex2D(P1, uv).x;  
float p2 = tex2D(P2, uv).x;  
float continued = 0;
float returned = 0;
Current.color = float4(p1, p2, continued, returned);
