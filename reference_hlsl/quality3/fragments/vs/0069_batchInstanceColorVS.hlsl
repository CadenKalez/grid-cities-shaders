// Shader fragment  [VS slot 69]  batchInstanceColorVS

// ---- uniform parameters ----
uniform float4 batchColors[48];   // reg-meta 02a302a30030000000000008

// ---- fragment body (spliced into the generated main()) ----
int meshBatchIndex4 = toInt(Current.indices.x);
float4 rawInstanceInfo = batchColors[meshBatchIndex4];
float4 instanceColor = rawInstanceInfo;
float4 instanceData = float4(1, 1, 1, rawInstanceInfo.w);
