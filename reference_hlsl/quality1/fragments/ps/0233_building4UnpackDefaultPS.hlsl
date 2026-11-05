// Shader fragment  [PS slot 233]  building4UnpackDefaultPS

// ---- uniform parameters ----
uniform float4 worldCameraDirection;   // reg-meta 002100210001000000004000

// ---- fragment body (spliced into the generated main()) ----
float4 color1 = floor(In.color) * (1.0 / 255.0); // deal with interpolator inaccuracy caused by perspective correction
float2 uv = In.texcoord<t0>.xy;
float2 uv2 = In.texcoord<t0>.zw;
float3 eyeDir = In.texcoord<t1>.xyz;
float palU = In.texcoord<t1>.w;
float3 shColorDiff = In.texcoord<t7>.xyz;
float palU2 = In.texcoord<t2>.w;
float3 shColorSpec = In.color1.xyz; // not used
float buildingVariation = In.texcoord<t2>.y;
float2 interiorSize = In.texcoord<t3>.xx;
float2 interiorRoomInvSize = In.texcoord<t3>.xy;
float2 tilePadding = In.texcoord<t3>.zw;
float4 regionXform = In.texcoord<t4>;
float4 regionXform2 = In.texcoord<t5>;
float3 worldNormal = In.texcoord<t6>.xyz;
float interiorRandomSeed = In.texcoord<t6>.w;
float3 worldTangent = float3(0,1,0); // not used
float3 interiorThresholds = color1.xyz;
float interiorScale = In.texcoord<t2>.z;
float interiorOffset = color1.w;
float3 worldViewDirection = worldCameraDirection.xyz;
