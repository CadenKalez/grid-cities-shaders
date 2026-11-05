// Shader fragment  [PS slot 223]  csgThicknessPS

// ---- declarations / helper functions ----
extern uniform sampler P1P2 : register(s0);

// ---- fragment body (spliced into the generated main()) ----
float2 uv = In.texcoord<t0>.xy;
float2 p1p2 = tex2D(P1P2, uv).xy;
float p1 = p1p2.x;
float p2 = p1p2.y;
float thickness = max(0, p1 - p2);
Current.color = float4(thickness, 0, 0, 0);
