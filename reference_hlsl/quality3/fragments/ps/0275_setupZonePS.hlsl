// Shader fragment  [PS slot 275]  setupZonePS

// ---- fragment body (spliced into the generated main()) ----
float4 texCoord = In.texcoord<t0>;
float4 tangent = In.texcoord<t2>;
float camDistance = In.texcoord<t3>.x;
float vertAlpha = In.color.a;
