// Shader fragment  [PS slot 261]  vehicleInteriorPS

// ---- declarations / helper functions ----
static const float interior_invDepth          = 1.5;     
static const float interior_backTexSize       = 0.5;     
static const float interior_diffuseOverbright = 18.0f;
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

// ---- fragment body (spliced into the generated main()) ----
// Calculate interior colour.
float2 interiorUv    = uv1;
float2 interiorSrcUv = frac( interiorUv );
float2 interior_tc   = interiorMap( eyeDir, interiorSrcUv, interior_invDepth, interior_backTexSize, 1 );
float3 interiorMap   = tex2D( interiorSampler, interior_tc ).rgb * interior_diffuseOverbright;
finalColor = lerp( interiorMap, finalColor, selfIllumMask.b );
