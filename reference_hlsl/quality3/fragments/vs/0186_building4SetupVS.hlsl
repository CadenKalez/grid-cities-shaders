// Shader fragment  [VS slot 186]  building4SetupVS

// ---- uniform parameters ----
uniform float4x3 worldToCamera;   // reg-meta 000e000e0003000000004000
uniform float4x3 modelToCamera;   // reg-meta 000700070003000000004001

// ---- declarations / helper functions ----
static const int2  kPaletteSize = int2(256, 8);
static const float2 kPaletteInvSize = 1.0 / kPaletteSize;
// Convert from byte-represented color (0-1) to U value within texture
float BuildingPaletteVS(float palU)
{
// move to corner of 2x2 block
palU = palU * ((kPaletteSize.x - 1) * kPaletteInvSize.x);
return palU;
}
float BuildingPaletteVariationVS(int buildingType)
{
return buildingType * kPaletteInvSize.y;
}
float FastNoise(float3 seed)
{
seed *= float3(78.233, 12.9898, 43758.5453);
seed += float3(0.819 * 78.233, 0.819 * 12.9898, 0.819 * 43758.5453);
float random = frac(seed.z * frac(seed.x * frac(seed.y)));
return random;
}
static const float kNumTextureTiles  = 16;  
static const float kWorldTextureSize = 16;  
static const float kWorldToTextureRatio = kWorldTextureSize / kNumTextureTiles;

// ---- fragment body (spliced into the generated main()) ----
// should really use inverse transpose here but we use affine camera matrices so it doesn't matter
float3 viewTangent = mul(float4(worldTangent,0), worldToCamera).xyz;
float3 viewBinormal = mul(float4(worldBinormal,0), worldToCamera).xyz;
float3 viewNormal = mul(float4(worldNormal,0), worldToCamera).xyz;
float3 viewPos = mul(float4(Current.position.xyz,1), modelToCamera).xyz;
float3x3 tangentSpace = float3x3(viewTangent, viewBinormal, viewNormal);
float3 eyeDir = -mul(tangentSpace, viewPos);
// unpack palettes
float palU = BuildingPaletteVS(In.color.r);
float palU2 = BuildingPaletteVS(In.color.g);
// unpack interior data
// texture location:
// 4 bits size (1 to 16)
// 4 bits index (0 to size-1)
float interiorTexData = In.color.b * (16 * 255.0 / 256.0);
int interiorSize = int(floor(interiorTexData)) + 1;
int interiorSelection = int(floor(frac(interiorTexData) * 16));
float interiorScale = 1.0f / interiorSize;
float interiorOffset = interiorSelection * interiorScale;
// random seed straight from data
float interiorRandomSeed = In.color.a;
// munge interior random seed by model position
int2 quantizedModelPosition = int2(floor(modelPos.xy * 2));
if(interiorRandomSeed < 0.5)
interiorRandomSeed = FastNoise(float3(quantizedModelPosition, interiorRandomSeed));
// unpack other texture coords
float2 tileSize = In.texcoord1.xy;
float2 tileOffset = In.texcoord1.zw;
float2 tileSize2 = In.texcoord2.xy;
float2 tileOffset2 = In.texcoord2.zw;
float2 tilePadding = In.texcoord3.xy;
float2 interiorRoomInvSize = In.texcoord3.zw;
float2 uv = In.texcoord0.xy / abs(tileSize);
float2 uv2 = In.texcoord0.zw / abs(tileSize2);
uv2 += (tilePadding * .5);
uv2 /= (1 + tilePadding);
