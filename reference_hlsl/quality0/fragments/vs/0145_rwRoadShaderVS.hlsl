// Shader fragment  [VS slot 145]  rwRoadShaderVS

// ---- fragment body (spliced into the generated main()) ----
// Must add 1 thanks to RW exporter inverting V co-ordinate.
float2 uv0 = In.texcoord0.xy;
uv0.y += 1.0f;
Current.texcoord<t0>.xyz = float3( uv0, 0.0f );
Current.texcoord<t1>.xyz = worldTangent;
Current.texcoord<t2>.xyz = worldNormal;
