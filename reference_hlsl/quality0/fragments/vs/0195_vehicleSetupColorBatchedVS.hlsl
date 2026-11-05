// Shader fragment  [VS slot 195]  vehicleSetupColorBatchedVS

// ---- fragment body (spliced into the generated main()) ----
// batchInstanceInfo[].color no longer exists! Since this batched path is
// only used for construction caps that are still using the vehicle shader, I'm setting
// this misc params values to be all 1. At some point they should be changed to use the
// building one. I have no idea is this causes any visual issues by doing this.
float4 miscParams = float4( 1.0f, 1.0f, 1.0f, 1.0f );
