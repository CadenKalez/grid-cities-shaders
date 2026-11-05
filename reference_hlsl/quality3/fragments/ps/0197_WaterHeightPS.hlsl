// Shader fragment  [PS slot 197]  WaterHeightPS

// ---- uniform parameters ----
uniform struct { float4 mParams; float4 mGridSizes; } waterHeightInfo;   // reg-meta 028802880002000000000008

// ---- declarations / helper functions ----
extern uniform sampler HeightMap : register(s0);

// ---- fragment body (spliced into the generated main()) ----
const float gridScale = waterHeightInfo.mParams.y;
const float heightScale = waterHeightInfo.mParams.z;
const float4 GRID_SIZES = waterHeightInfo.mGridSizes;
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
uv *= gridScale;
float height = 0.0;
height += tex2D(HeightMap, float2(uv / GRID_SIZES.x) ).x;
height += tex2D(HeightMap, float2(uv / GRID_SIZES.y) ).y;
height += tex2D(HeightMap, float2(uv / GRID_SIZES.z) ).z;
height += tex2D(HeightMap, float2(uv / GRID_SIZES.w) ).w;
height *= heightScale;
Current.color = float4(height, 0,0,0);
