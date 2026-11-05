// Shader fragment  [PS slot 198]  WaterChoppyPS

// ---- uniform parameters ----
uniform struct { float4 mParams; float4 mGridSizes; } waterChoppyInfo;   // reg-meta 028902890002000000000008

// ---- declarations / helper functions ----
extern uniform sampler ChoppyMap1 : register(s0);
extern uniform sampler ChoppyMap2 : register(s1);

// ---- fragment body (spliced into the generated main()) ----
const float gridScale = waterChoppyInfo.mParams.y;
const float choppyScale = waterChoppyInfo.mParams.z;
const float choppyHeight = waterChoppyInfo.mParams.w;
const float4 GRID_SIZES = waterChoppyInfo.mGridSizes;
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
uv *= gridScale;
float2 choppy = float2(0.0, 0.0);
choppy += tex2D(ChoppyMap1, float2(uv / GRID_SIZES.x) ).xy;
choppy += tex2D(ChoppyMap1, float2(uv / GRID_SIZES.y) ).zw;
choppy += tex2D(ChoppyMap2, float2(uv / GRID_SIZES.z) ).xy;
choppy += tex2D(ChoppyMap2, float2(uv / GRID_SIZES.w) ).zw;
choppy *= choppyScale;
float3 C = normalize(float3(-choppy.x, choppyHeight, -choppy.y));
Current.color = float4(C.x, C.y, C.z, 0);
