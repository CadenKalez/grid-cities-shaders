// Shader fragment  [VS slot 198]  worldSpaceBatchedTangent1

// ---- uniform parameters ----
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];   // reg-meta 02bf02bf0090000000000008

// ---- fragment body (spliced into the generated main()) ----
int vehiclesIndex1 = toInt( Current.indices.x );
float3 worldTangent1 = normalize( quatrot( batchInstanceInfo[ vehiclesIndex1 ].rotation, Current.tangent1.xyz ) );
