// Shader fragment  [PS slot 445]  selectionEdgeDetect

// ---- uniform parameters ----
uniform float4 worldCameraPosition;   // reg-meta 001f001f0001000000004000
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000
uniform struct {float4 highlightColor;float4 selectionColor;float4 glowInfo;float4 distances;} unitHighlightInfo;   // reg-meta 02d602d60004000000000008

// ---- declarations / helper functions ----
extern uniform sampler colorBuffer : register(s0);

// ---- fragment body (spliced into the generated main()) ----
const float4 ONE = float4(1,1,1,1);
const float kMaxCameraDist = 2800.0f;
const float kMaxDist = kMaxCameraDist * kMaxCameraDist;
const float kMinDivisor = 1.0f / 7.8f;
const float kMaxDivisor = 1.0f / 9.0f;
float2 texOffset = float2(renderTargetInfo0.zw);
float2 uv = In.texcoord<t0>.xy;
// Sample 3x3 box
float4 center = tex2D(colorBuffer, uv);
float4 south = tex2D(colorBuffer, uv + texOffset * float2(0,1));
float4 west = tex2D(colorBuffer, uv + texOffset * float2(1,0));
float4 north = tex2D(colorBuffer, uv + texOffset * float2(0,-1));
float4 east = tex2D(colorBuffer, uv + texOffset * float2(-1,0));
float4 nw = tex2D(colorBuffer, uv  + texOffset * float2(1,-1));
float4 ne = tex2D(colorBuffer, uv  + texOffset * float2(-1,-1));
float4 sw = tex2D(colorBuffer, uv  + texOffset * float2(1,1));
float4 se = tex2D(colorBuffer, uv  + texOffset * float2(-1,1));
float heightAtten = 1.0f;
float distToHighlight = unitHighlightInfo.distances.x;
float distToSelection = unitHighlightInfo.distances.y;
float finalDist = max(distToHighlight, distToSelection);
float fillAtten = saturate(finalDist / kMaxDist);
float divisor = lerp(kMaxDivisor, kMinDivisor, fillAtten);
float4 accum = (center + north + nw + ne + east + west + south + sw + se) * divisor;
float4 diff = abs(accum - center);
float diffAmount = dot(diff, ONE);
Current.color = diffAmount > 0.0 ? float4(accum.rgb, saturate(diffAmount * heightAtten)) : float4(0,0,0,0);
