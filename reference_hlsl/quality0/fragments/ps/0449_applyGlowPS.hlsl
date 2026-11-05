// Shader fragment  [PS slot 449]  applyGlowPS

// ---- uniform parameters ----
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform struct {float4 highlightColor;float4 selectionColor;float4 glowInfo;float4 distances;} unitHighlightInfo;   // reg-meta 02d602d60004000000000008

// ---- declarations / helper functions ----
extern uniform sampler outlineBuffer : register(s0);

// ---- fragment body (spliced into the generated main()) ----
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
float finalGlow = (maxGlow + minGlow) * 0.5f;
Current.color = float4(finalColor.rgb * finalGlow, saturate(center.a * finalColor.a));
