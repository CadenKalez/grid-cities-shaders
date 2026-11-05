// Shader fragment  [PS slot 251]  vehicleUnpackDefaultPS

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float3 worldNormal   = In.texcoord<t0>.xyz; // from vehicleOutputDefaultVS.
float3 worldTangent  = In.texcoord<t1>.xyz;
float3 worldPosition = In.texcoord<t2>.xyz;
float2 uv0           = float2( In.texcoord<t0>.w, In.texcoord<t1>.w );
float4 miscParams    = In.texcoord<t3>;
float3 viewVec = normalize( worldPosition - worldCameraPosition.xyz );
