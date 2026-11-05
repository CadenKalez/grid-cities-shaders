// Shader fragment  [VS slot 65]  toWorldSpaceBatched

// ---- uniform parameters ----
uniform struct { float4 translation; float4 rotation; float4 animdata; } batchInstanceInfo[48];   // reg-meta 02bf02bf0090000000000008

// ---- declarations / helper functions ----
float3 batchedQuat(float4 q, float3 v)
{
q *= 1.41421356237; // sqrt(2.0);
return v + cross(q.xyz, cross(q.xyz, v) + q.w * v);
}

// ---- fragment body (spliced into the generated main()) ----
int meshBatchIndex1 = toInt(Current.indices.x);
Current.position.xyz *= batchInstanceInfo[meshBatchIndex1].translation.w;
Current.position.xyz = batchedQuat(batchInstanceInfo[meshBatchIndex1].rotation, Current.position.xyz);
Current.position.xyz += batchInstanceInfo[meshBatchIndex1].translation.xyz;
