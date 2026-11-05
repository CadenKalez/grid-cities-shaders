// Shader fragment  [PS slot 235]  building4UnpackCombinePS

// ---- uniform parameters ----
uniform float4 screenInfo;   // reg-meta 020402040001000000000008
uniform float4 worldFarCorners[4];   // reg-meta 02b602b60004000000000008

// ---- fragment body (spliced into the generated main()) ----
float4 col = floor(In.color) * (1.0 / 255.0); // deal with interpolator inaccuracy caused by perspective correction
float2 uv = In.texcoord<t0>.xy;
float2 uv2 = In.texcoord<t0>.zw;
float3 eyeDir = In.texcoord<t1>.xyz;
float palU = In.texcoord<t1>.w;
float3 shColorDiff = float3(0.0,0.0,0.0);
float palU2 = In.texcoord<t2>.w;
float3 shColorSpec = float3(0.0,0.0,0.0);
float buildingVariation = In.texcoord<t2>.z;
float interiorScale = In.texcoord<t3>.x;
float interiorOffset = In.texcoord<t3>.y;
float2 tilePadding = In.texcoord<t3>.zw;
float4 regionXform = In.texcoord<t4>;
float4 regionXform2 = In.texcoord<t5>;
float3 interiorThresholds = col.xyz;
float interiorRandomSeed = col.w;
float2 screenUV = (In.vpos.xy+float2(0.5,0.5)) * screenInfo.zw;
float3 worldViewDirection = normalize(lerp(lerp(worldFarCorners[1],worldFarCorners[0],screenUV.y),lerp(worldFarCorners[3],worldFarCorners[2],screenUV.y),screenUV.x)).xyz;
float2 interiorRoomInvSize = In.texcoord<t2>.xy;
