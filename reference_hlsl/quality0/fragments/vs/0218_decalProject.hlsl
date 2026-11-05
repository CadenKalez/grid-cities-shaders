// Shader fragment  [VS slot 218]  decalProject

// ---- uniform parameters ----
uniform float4x3 cameraToWorld;   // reg-meta 000d000d0003000000004000

// ---- fragment body (spliced into the generated main()) ----
float3x4 cameraToWorldT = transpose(cameraToWorld);
float4x4 cameraToWorld44 = float4x4(
cameraToWorldT[0],
cameraToWorldT[1],
cameraToWorldT[2],
float4(0,0,0,1));
float invSqrMWScale = 1.0 / dot(modelToWorld[0].xyz, modelToWorld[0].xyz);
float3x3 modelToWorldT33 = transpose(make_float3x3(modelToWorld)) * invSqrMWScale;
float3   newTranslation  = -mul(modelToWorldT33, float3(modelToWorld[0].w, modelToWorld[1].w, modelToWorld[2].w));
float4x4 worldToModel = float4x4(
float4(modelToWorldT33[0], newTranslation.x),
float4(modelToWorldT33[1], newTranslation.y),
float4(modelToWorldT33[2], newTranslation.z),
float4(0,0,0,1));
float4x4 cameraToModel = mul(worldToModel, cameraToWorld44);
float4x4 cameraToTexture = mul(float4x4(modelToTexture[0], modelToTexture[1], modelToTexture[2], float4(0,0,0,1)), cameraToModel);
Current.texcoord<t0> = cameraToTexture[0];
Current.texcoord<t1> = cameraToTexture[1];
Current.texcoord<t2> = cameraToTexture[2];
