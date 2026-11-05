// Shader fragment  [VS slot 241]  impostorTreeVS

// ---- uniform parameters ----
uniform struct { float4 projScale; float4 projOffset; float4 scale[8]; float4 offset[8]; float4x4 transform[8];} scImpostorAtlasPosition;   // reg-meta 02a202a20032000000000008
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000

// ---- fragment body (spliced into the generated main()) ----
float leavesFallen = scImpostorAtlasPosition.projScale.w;
Current.texcoord<t0> = float4(In.texcoord0.xy + float2(0, 1), In.texcoord1.xy + float2(0, 1));
Current.position.xyz = mul(float4(Current.position.xyz,0), scImpostorAtlasPosition.transform[angle]).xyz;
Current.position.xyz = mul(float4(Current.position.xyz,0), worldToCamera).xyz;
Current.position.xyz *= scImpostorAtlasPosition.projScale.xyz;
Current.position.xyz += scImpostorAtlasPosition.projOffset.xyz;
Current.texcoord<t1> = float4(Current.position.xyz, 0);
Current.position.xyz *= scImpostorAtlasPosition.scale[angle].xyz;
Current.position.xyz += scImpostorAtlasPosition.offset[angle].xyz;
float3 vertNormal = Current.normal.xyz;
vertNormal = mul(float4(vertNormal, 0), scImpostorAtlasPosition.transform[angle]).xyz;
Current.texcoord<t2> = float4(vertNormal, leavesFallen);
float3 vertTangent = Current.tangent.xyz;
vertTangent = mul(float4(vertTangent, 0), scImpostorAtlasPosition.transform[angle]).xyz;
Current.texcoord<t3> = float4(vertTangent, 0);
