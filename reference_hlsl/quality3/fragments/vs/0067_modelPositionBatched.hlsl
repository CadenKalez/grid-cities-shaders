// Shader fragment  [VS slot 67]  modelPositionBatched

// ---- uniform parameters ----
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];   // reg-meta 02bf02bf0090000000000008

// ---- fragment body (spliced into the generated main()) ----
int meshBatchIndex3 = toInt(Current.indices.x);
float3 modelPos = batchInstanceInfo[meshBatchIndex3].translation.xyz;
