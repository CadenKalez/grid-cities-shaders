// Shader fragment  [PS slot 502]  filmicMapPS

// ---- declarations / helper functions ----
extern uniform sampler map : register(s0);
static const float tmShoulderStrength  = 0.15;
static const float tmLinearStrength    = 0.50;
static const float tmLinearAngle       = 0.10;
static const float tmToeStrength       = 0.20;
static const float tmToeNumerator      = 0.02;
static const float tmToeDenominator    = 0.30;
/*
static const float tmShoulderStrength  = 0.22;
static const float tmLinearStrength    = 0.30;
static const float tmLinearAngle       = 0.10;
static const float tmToeStrength       = 0.20;
static const float tmToeNumerator      = 0.01;
static const float tmToeDenominator    = 0.30;
*/
static const float tmBaseWhite         = 11.2;
float3 toneMap(float3 inColor)
{
return ((inColor*(tmShoulderStrength*inColor + tmLinearAngle*tmLinearStrength) + tmToeStrength*tmToeNumerator) /
(inColor*(tmShoulderStrength*inColor + tmLinearStrength) + tmToeStrength*tmToeDenominator)) - tmToeNumerator/tmToeDenominator;
}

// ---- fragment body (spliced into the generated main()) ----
float3 texColor = pow(tex2D(map, In.texcoord0).rgb, float3(2.2, 2.2, 2.2));
//texColor *= 16;  // Hardcoded Exposure Adjustment
// uncharted
float exposureBias = 2.0;
float3 tmColor = toneMap(exposureBias * texColor);
float3 whiteScale = 1.0/toneMap(tmBaseWhite);
float3 outColor = tmColor*whiteScale;
outColor = pow(outColor,1/float3(2.2, 2.2, 2.2));
Current.color.rgba = float4(outColor,1);
