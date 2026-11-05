// Shader fragment  [PS slot 471]  performAdaptiveDoFNoDepthPS

// ---- uniform parameters ----
uniform struct { float4 dofFocusPlane; float4 dofFocusDistances; float4 dofLerpScale;float4 dofLerpBias;} tiltShiftDOFInfo;   // reg-meta 02a502a50004000000000008

// ---- declarations / helper functions ----
extern uniform sampler color : register(s0);

// ---- fragment body (spliced into the generated main()) ----
// Diameter of max CoC
float maxCoC = tiltShiftDOFInfo.dofFocusPlane.x * maxCoCSize * 0.5f;
float4 centerColor = tex2D(color, In.texcoord0.xy);
float centerCoCRadius = max(centerColor.a * maxCoC, epsilon.x);
float accumWeights = gaussianWeights[0] / (centerCoCRadius * centerCoCRadius);
float4 accum = centerColor * accumWeights;
for (int i = 1; i <= sampleRadius; i+=2)
{
float4 finalOffset = float4(texOffset * i, texOffset * (i+1));
float4 texcoordLeft = In.texcoord0.xyxy - finalOffset;
float4 texcoordRight = In.texcoord0.xyxy + finalOffset;
// Alpha channel stores pixel's CoC from half-res downsample
float4 colorLeft = tex2D(color, texcoordLeft.xy);
float4 colorFarLeft = tex2D(color, texcoordLeft.zw);
float4 colorRight = tex2D(color, texcoordRight.xy);
float4 colorFarRight = tex2D(color, texcoordRight.zw);
float4 radii = float4(colorLeft.a, colorFarLeft.a, colorRight.a, colorFarRight.a) * maxCoC;
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
accum += colorLeft * weights.x +
colorFarLeft * weights.y +
colorRight * weights.z +
colorFarRight * weights.w;
accumWeights += dot(weights, float4(1,1,1,1));
}
accum /= accumWeights;
Current.color = float4(accum.rgb, centerColor.a);
// 36 bytes of texture data sampled per pixel
