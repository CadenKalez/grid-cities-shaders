// Material shader: roadMaskShaderOld
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
    // --- fragment: copyUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: roadMaskVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = In.texcoord1.xyz;
    Current.texcoord<t1>.xyz = worldPosition.xyz;
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
static const bool kUseFlattenHull = false;
static const float kEnableLerp = 1.0;
uniform float4 renderTargetInfo0;
sampler2D heightMapSampler : register(s14);
// For positive acceleration, the road will be drawn below terrain because it's concave while control map sampling is linear
// We want to calculate a height offset to push the terrain down further to prevent this from happening
// For negative acceleration, we're not adjusting for that right now since it's convex but theoretically we need to take into
// account the tessellation errors since the tessellated mesh will be below the curve.
// TODO: account for the negative acceleration's tessellation errors as well
float CalculateHeightOffsetFromAcceleration(float verticalAcceleration)
{
verticalAcceleration = max(verticalAcceleration, 0.0); // negative acceleration is fine so we ignore them
float2 distMeters = 2048 * renderTargetInfo0.zw; 
float distMeter = max(distMeters.x, distMeters.y); 
float curvatureHeightOffset = -verticalAcceleration * 0.125 * distMeter * distMeter;
curvatureHeightOffset *= 8;
return curvatureHeightOffset;
}

void main_pixel()
{
    // --- fragment: roadMaskPSOldConfig   (cond 0000000000000000000000000000000000000000000000ff)
    bool clipAboveTerrain = false;
    bool clipBridge = false;
    // --- fragment: roadMaskEnableFlattenLerp   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: roadMaskPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv0 = In.texcoord<t0>.xy;
    float3 uv1 = In.texcoord<t1>.xyz;
    float maskColor = (uv0.x >= 0 && uv0.x <= 1 && uv0.y >= 0 && uv0.y <= 1) ? 1 : 0;
    if (!kUseFlattenHull)
    maskColor = 1;
    float3 worldPosition = In.texcoord<t2>.xyz;
    float terrainHeight = tex2D(heightMapSampler, (worldPosition.xy + 1024.0) / 2048.0).x;  
    float roadHeight = worldPosition.z + 1024.0;
    if (kUseFlattenHull)
    {
    float zAcceleration = uv1.x;
    float curvatureHeightOffset = CalculateHeightOffsetFromAcceleration(zAcceleration);
    roadHeight += curvatureHeightOffset;
    }
    roadHeight /= 2048.0;  
    float distToTerrain = (roadHeight - terrainHeight) * 2048;  
    if (clipAboveTerrain)
    {
    float heightAdjustment = 5.0 / 2048.0; 
    clip(roadHeight + heightAdjustment - terrainHeight);
    }
    if (clipBridge)
    {
    float heightAdjustment = 50.0 / 2048.0;
    clip((terrainHeight + heightAdjustment) - roadHeight);
    }
    const float flattenTolerance = 12.0;  
    const float lerpTolerance    = 16.0;  
    const float terrainBias      = 0.0;  
    float adjustment = kEnableLerp*saturate((distToTerrain - flattenTolerance) / (lerpTolerance - flattenTolerance));
    float adjustedHeight = lerp(roadHeight, terrainHeight, adjustment);
    adjustedHeight += terrainBias / 2048.0;
    adjustedHeight = saturate(adjustedHeight);
    adjustedHeight = adjustedHeight * 255.0;
    Current.color.xyzw = float4(floor(adjustedHeight) / 255.0, floor(frac(adjustedHeight)*255.0) / 255.0, 1-adjustment/*maskColor*/, maskColor);
}
