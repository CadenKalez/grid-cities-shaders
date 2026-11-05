// Shader fragment  [VS slot 206]  copyZoneUVsNormals

// ---- fragment body (spliced into the generated main()) ----
int lotsIndex1 = toInt(In.indices.x);
Current.texcoord<t0> = In.texcoord0;
Current.texcoord<t1> = float4(In.normal.xyz,lotsIndex1);
Current.texcoord<t2> = float4(In.tangent.xyz,In.position.z);
