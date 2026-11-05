// Shader fragment  [PS slot 252]  vehicleUnpackDeferredPS

// ---- fragment body (spliced into the generated main()) ----
float3 worldNormal   = In.texcoord<t0>.xyz; // from vehicleOutputDeferredVS.
float3 worldTangent  = In.texcoord<t1>.xyz;
float3 worldPosition = In.texcoord<t2>.xyz;
float2 uv0           = float2( In.texcoord<t0>.w, In.texcoord<t1>.w );
