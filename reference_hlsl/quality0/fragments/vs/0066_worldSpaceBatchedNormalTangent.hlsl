// Shader fragment  [VS slot 66]  worldSpaceBatchedNormalTangent

// ---- uniform parameters ----
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];   // reg-meta 02bf02bf0090000000000008

// ---- declarations / helper functions ----
float3 quatrot(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}

// ---- fragment body (spliced into the generated main()) ----
int meshBatchIndex2 = toInt(Current.indices.x);
float3 worldNormal = normalize(quatrot(batchInstanceInfo[meshBatchIndex2].rotation, Current.normal.xyz));
float3 worldTangent = normalize(quatrot(batchInstanceInfo[meshBatchIndex2].rotation, Current.tangent.xyz));
float3 worldBinormal = cross( worldTangent, worldNormal );
