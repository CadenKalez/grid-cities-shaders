// Shader fragment  [VS slot 166]  planeWaterVS

// ---- uniform parameters ----
uniform float4x4 modelToClip;   // reg-meta 000600060004000000004001
uniform struct { float4 mWaterInfo; float4 mReflectionParams; float4 mScaleAndBias1; float4 mScaleAndBias2; } terrainSurfaceInfoVS;   // reg-meta 028102810004000000000008

// ---- declarations / helper functions ----
sampler WaterHeightMapVS   : register(s0);  
sampler ChoppyMapVS        : register(s1);  
sampler TerrainHeightMapVS : register(s2);

// ---- fragment body (spliced into the generated main()) ----
{
Current.texcoord0 = Current.position.xyxy / 16384;
Current.texcoord1 = float4(0,0,1,0);  
Current.texcoord2.w = 1;
float2 uv1 = Current.position.xy;
uv1 /= 2048.0;
uv1 += 0.5;
uv1 = saturate(uv1);
float seaLevel = terrainSurfaceInfoVS.mWaterInfo.x;  
float thickness = 0;  
Current.texcoord2.w = thickness;  
float3 worldPos = float3(Current.position.xy, seaLevel);
Current.position.xyzw = float4(worldPos, 1);
float4 clipPosition = mul(Current.position, modelToClip);
Current.texcoord<t3>.xyzw = clipPosition;
Current.position.x *= terrainSurfaceInfoVS.mScaleAndBias1.x;
Current.position.x += terrainSurfaceInfoVS.mScaleAndBias1.y;
Current.position.y *= terrainSurfaceInfoVS.mScaleAndBias1.z;
Current.position.y += terrainSurfaceInfoVS.mScaleAndBias1.w;
Current.texcoord2.xyz = Current.position.xyz;
}
