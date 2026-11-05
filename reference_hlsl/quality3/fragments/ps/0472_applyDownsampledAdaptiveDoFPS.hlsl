// Shader fragment  [PS slot 472]  applyDownsampledAdaptiveDoFPS

// ---- uniform parameters ----
uniform float4 renderTargetInfo0;   // reg-meta 025a025a0001000000004000

// ---- declarations / helper functions ----
extern uniform sampler adaptiveDoF : register(s0);
extern uniform sampler adaptiveDoF2 : register(s14);

// ---- fragment body (spliced into the generated main()) ----
static const float2 denom = float2(1.0f / 0.33f, 1.0f / (1.0f - 0.33f));
float currCoC = computePixelCoC(In.texcoord0.xy);
// Perform 3-way linear blend between in-focus, out-of-focus, and super-out-of-focus.
// In-focus blending happens via the final alpha blend with the color buffer.
// CoC between 0.33 - 1.0 lerps between out-of-focus and super-out-of-focus
float2 blendWeight = float2(min(currCoC, 0.33f), saturate(currCoC - 0.33f)) * denom;
float4 outOfFocus = tex2D(adaptiveDoF, In.texcoord0.xy);
float4 superOutOfFocus = tex2D(adaptiveDoF2, In.texcoord0.xy);
// Alpha channel stores calculated CoC for that pixel. Due to downsampling, the CoCs
// need not match so we bias towards the higher res blur if there is a discrepancy
// between CoC.
blendWeight.y = saturate(blendWeight.y - (outOfFocus.a - superOutOfFocus.a) * 2.0f);
float4 finalColor = lerp(outOfFocus, superOutOfFocus, blendWeight.y);
Current.color = finalColor * blendWeight.x;
Current.color.a = blendWeight.x;
// 12 bytes of texture data sampled per pixel
