// Shader fragment  [VS slot 70]  batchInstanceDataVS

// ---- uniform parameters ----
uniform float4 batchDatas[48];   // reg-meta 02a402a40030000000000008

// ---- fragment body (spliced into the generated main()) ----
int meshBatchIndex5 = toInt(Current.indices.x);
float4 rawInstanceInfo = batchDatas[meshBatchIndex5];
float4 instanceColor = float4(1, 1, 1, rawInstanceInfo.w);
float4 instanceData = rawInstanceInfo;
