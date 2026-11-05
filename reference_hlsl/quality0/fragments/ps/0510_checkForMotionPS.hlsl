// Shader fragment  [PS slot 510]  checkForMotionPS

// ---- declarations / helper functions ----
extern uniform sampler currentColorTexture : register(s1);
extern uniform sampler oldColorTexture : register(s2);

// ---- fragment body (spliced into the generated main()) ----
const float kColorErrFactor = 256.0;
float4 curColor = tex2D(currentColorTexture, In.texcoord0.xy);
float4 oldColor = tex2D(oldColorTexture, In.texcoord0.xy);
float3 colorDiff = oldColor.xyz - curColor.xyz;
float  colorErr  = dot(colorDiff, colorDiff) * kColorErrFactor;
Current.color = float4(curColor.xyz, colorErr);
