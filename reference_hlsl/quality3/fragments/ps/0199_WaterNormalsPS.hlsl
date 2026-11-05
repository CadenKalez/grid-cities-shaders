// Shader fragment  [PS slot 199]  WaterNormalsPS

// ---- uniform parameters ----
uniform struct { float4 mParams; float4 mGridSizes; } waterNormalsInfo;   // reg-meta 028a028a0002000000000008

// ---- declarations / helper functions ----
extern uniform sampler SlopesMap1 : register(s0);
extern uniform sampler SlopesMap2 : register(s1);

// ---- fragment body (spliced into the generated main()) ----
const float gridScale = waterNormalsInfo.mParams.y;
const float normalScale = waterNormalsInfo.mParams.z;
const float normalHeight = waterNormalsInfo.mParams.w;
const float4 GRID_SIZES = waterNormalsInfo.mGridSizes;
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
uv *= gridScale;
float2 slopes = float2(0,0);
slopes += tex2D(SlopesMap1, float2(uv / GRID_SIZES.x) ).xy;
slopes += tex2D(SlopesMap1, float2(uv / GRID_SIZES.y) ).zw;
slopes += tex2D(SlopesMap2, float2(uv / GRID_SIZES.z) ).xy;
slopes += tex2D(SlopesMap2, float2(uv / GRID_SIZES.w) ).zw;
slopes *= normalScale;
float3 N = normalize(float3(-slopes.x, -slopes.y, normalHeight));
Current.color = float4(N * 0.5 + 0.5, 0);
