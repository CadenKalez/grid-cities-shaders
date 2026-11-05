// Shader fragment  [PS slot 380]  regionCityBuildingsUnpackPS

// ---- fragment body (spliced into the generated main()) ----
float2 uv                  = In.texcoord<t0>.xy;
float2 uv2                 = In.texcoord<t0>.zw;
float4 regionXform         = In.texcoord<t1>;
float4 regionXform2        = In.texcoord<t2>;
float2 tilePadding         = In.texcoord<t3>.xy;
float  palU                = In.texcoord<t3>.z;
float  palU2               = In.texcoord<t3>.w;
float4 position            = In.texcoord<t4>.xyzw;
float2 interiorRoomInvSize = In.texcoord<t5>.xy;
float  interiorLightTime   = In.texcoord<t5>.z;
float  poweredState        = In.texcoord<t5>.w;
