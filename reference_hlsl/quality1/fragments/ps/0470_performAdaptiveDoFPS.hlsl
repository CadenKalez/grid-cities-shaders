// Shader fragment  [PS slot 470]  performAdaptiveDoFPS

// ---- uniform parameters ----
uniform struct { float4 dofFocusPlane; float4 dofFocusDistances; float4 dofLerpScale;float4 dofLerpBias;} tiltShiftDOFInfo;   // reg-meta 02a502a50004000000000008

// ---- declarations / helper functions ----
extern uniform sampler color : register(s0);

// ---- fragment body (spliced into the generated main()) ----
// Diameter of max CoC
float maxCoC = tiltShiftDOFInfo.dofFocusPlane.x * maxCoCSize * 0.5f;
float centerCoCRadius = computePixelCoC(In.texcoord0.xy);
// Store off current pixel CoC in alpha channel
Current.color.a = centerCoCRadius;
// Now get the actual radius
centerCoCRadius = max(centerCoCRadius * maxCoC, epsilon.x);
float accumWeights = gaussianWeights[0] / (centerCoCRadius * centerCoCRadius);
float4 accum = tex2D(color, In.texcoord0.xy) * accumWeights;
for (int i = 1; i <= sampleRadius; i+=2)
{
float4 finalOffset = float4(texOffset * i, texOffset * (i+1));
float4 texcoordLeft = In.texcoord0.xyxy - finalOffset;
float4 texcoordRight = In.texcoord0.xyxy + finalOffset;
float4 radii = computePixelCoC4(texcoordLeft, texcoordRight) * maxCoC;
// Compute overlap weight
float4 overlapWeights = radii - float4(i, i, i, i);
overlapWeights = lesser_than(radii, i) ? float4(0, 0, 0, 0) : overlapWeights;
overlapWeights = is_greater_equal(radii, i + 1) ? float4(1, 1, 1, 1) : overlapWeights;
// Compute intensity weight
float4 intensityWeights = 1.0f / max((radii * radii), epsilon);
// Compute leakage weight
float4 leakageWeights = saturate(radii / centerCoCRadius);
// Final weight
float4 weights = overlapWeights * intensityWeights * leakageWeights;
weights.xz *= gaussianWeights[i];
weights.yw *= gaussianWeights[i + 1];
accum += tex2D(color, texcoordLeft.xy) * weights.x +
tex2D(color, texcoordLeft.zw) * weights.y +
tex2D(color, texcoordRight.xy) * weights.z +
tex2D(color, texcoordRight.zw) * weights.w;
accumWeights += dot(weights, float4(1,1,1,1));
}
accum /= accumWeights;
Current.color.rgb = accum.rgb;
// 72 bytes of texture data sampled per pixel
