// Shader fragment  [PS slot 253]  vehicleUnpackCombinePS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000

// ---- fragment body (spliced into the generated main()) ----
float3 worldPosition  = In.texcoord<t0>.xyz; // from vehicleOutputCombineVS.
float2 uv0            = In.texcoord<t1>.xy;
float2 uv1            = In.texcoord<t1>.zw;
float3 eyeDir         = In.texcoord<t2>.xyz;
float4 miscParams     = In.texcoord<t3>;
float2 screenUV = ( In.vpos.xy + float2( 0.5f, 0.5f ) ) * screenInfo.zw;
float3 viewVec  = normalize( worldPosition - worldCameraPosition.xyz );
