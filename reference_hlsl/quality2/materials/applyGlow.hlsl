// Material shader: applyGlow
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 renderTargetInfo0;
uniform float4 worldCameraPosition;
uniform struct {float4 highlightColor;float4 selectionColor;float4 glowInfo;float4 distances;} unitHighlightInfo;
extern uniform sampler outlineBuffer : register(s0);

void main_pixel()
{
    // --- fragment: applyGlowPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float kMaxCameraDist = 1512.0f;
    const float3 ONE = float3(1,1,1);
    float minHighlightGlow = unitHighlightInfo.glowInfo.x;
    float maxHighlightGlow = unitHighlightInfo.glowInfo.y;
    float minSelectionGlow = unitHighlightInfo.glowInfo.z;
    float maxSelectionGlow = unitHighlightInfo.glowInfo.w;
    float4 highlightColor = unitHighlightInfo.highlightColor;
    float4 selectionColor = unitHighlightInfo.selectionColor;
    float2 texOffset = float2(renderTargetInfo0.zw);
    float2 uv = In.texcoord<t0>.xy;
    float4 center = tex2D(outlineBuffer, uv);
    // If both highlights are active, attenuate the selection values.
    float3 selectMask = ceil(center.rgb);
    selectMask.rgb /= dot(selectMask.rgb, ONE)+0.001f;
    float minGlow = minHighlightGlow * selectMask.r + minSelectionGlow * selectMask.g;
    float maxGlow = maxHighlightGlow * selectMask.r + maxSelectionGlow * selectMask.g;
    float4 finalColor = highlightColor * selectMask.r + selectionColor * selectMask.g;
    float cameraDist = length(worldCameraPosition);
    float cameraHeightAtten = saturate(cameraDist/kMaxCameraDist);
    float finalGlow = lerp(maxGlow, minGlow, cameraHeightAtten);
    Current.color = float4(finalColor.rgb * finalGlow, saturate(center.a * finalColor.a));
}
