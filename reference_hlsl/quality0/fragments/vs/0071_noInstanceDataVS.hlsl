// Shader fragment  [VS slot 71]  noInstanceDataVS

// ---- uniform parameters ----
uniform struct {float4 color;float4 data;} singleModelBatchData;   // reg-meta 02d902d90002000000000008

// ---- fragment body (spliced into the generated main()) ----
float4 rawInstanceInfo = singleModelBatchData.data;
float4 instanceColor = singleModelBatchData.color;
float4 instanceData = singleModelBatchData.data;
