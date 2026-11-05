// Shader fragment  [PS slot 240]  building4InteriorMapPS

// ---- declarations / helper functions ----
float2 interiorMap(float3 eye, float2 tc, float invMapDepth, float backSize, float dilation)
{
// shrink uvs by this much to avoid edge bleed near corners
const float kPadShrink = 0.9;
float3 eyeDir = eye;
eyeDir.z *= invMapDepth;
// Entrance position into the room
float3 pos = float3(tc, 0) * -2 + 1;
pos.z -= 1;
// clip to cube
float3 k = (sign(eyeDir) - pos) / eyeDir;
float t = min(k.x, min(k.y, k.z));
// target is now a point on the unit cube
float3 target = pos + t*eyeDir;
// do the perspective mapping
target.xy *= lerp(dilation, backSize, target.z);
return target.xy*-0.5 + 0.5;
}
float FastNoise(float3 seed)
{
seed *= float3(78.233, 12.9898, 43758.5453);
seed += float3(0.819 * 78.233, 0.819 * 12.9898, 0.819 * 43758.5453);
float random = frac(seed.z * frac(seed.x * frac(seed.y)));
return random;
}
static const float kBuildingInteriorMapInvDepth = 0.500000;
static const float kBuildingInteriorMapBackSize = 0.500000;
static const float kBuildingInteriorDilation = 0.900000;

// ---- fragment body (spliced into the generated main()) ----
float2 interiorUv = uv * regionXform.xy * interiorRoomInvSize;
int2 interiorElem = int2(floor(interiorUv));
float2 interiorSrcUv = frac(interiorUv);
// and we need to adjust eyeDir to fit the room size
float3 interiorEyeDir = eyeDir;
interiorEyeDir *= interiorRoomInvSize.xyx;
float2 interior_result_tc = interiorMap(interiorEyeDir, interiorSrcUv, kBuildingInteriorMapInvDepth, kBuildingInteriorMapBackSize, kBuildingInteriorDilation);
float2 interior_tc = interior_result_tc * make_float2(interiorScale) + float2(0, interiorOffset);
// Figure out what psuedo-random room we are in
float roomId = FastNoise(float3(interiorElem, interiorRandomSeed));
float roomVariation = floor(roomId * 4);  // choose between 4 possible room types
roomId = frac(roomId * 4);
// Choose an interior from the atlas based on the room id and the bin values
float4 interior_edge = float4(step(interiorThresholds, make_float3(roomId)), roomVariation * 4); 
float interior_offset = dot(interior_edge, float4(1, 1, 1, 1));
interior_tc.x += interior_offset * interiorScale;
