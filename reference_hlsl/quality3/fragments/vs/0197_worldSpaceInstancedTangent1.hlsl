// Shader fragment  [VS slot 197]  worldSpaceInstancedTangent1

// ---- fragment body (spliced into the generated main()) ----
float3 worldTangent1;
worldTangent1.x = dot( Current.tangent1.xyz, In.texcoord1.xyz );
worldTangent1.y = dot( Current.tangent1.xyz, In.texcoord2.xyz );
worldTangent1.z = dot( Current.tangent1.xyz, In.texcoord3.xyz );
worldTangent1 = normalize( worldTangent1 );
