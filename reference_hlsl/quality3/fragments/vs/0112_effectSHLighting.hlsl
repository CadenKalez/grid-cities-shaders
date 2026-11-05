// Shader fragment  [VS slot 112]  effectSHLighting

// ---- uniform parameters ----
uniform float4 shCoeffs[4];   // reg-meta 021a02190004000000000008

// ---- fragment body (spliced into the generated main()) ----
{
const static float kSH_A1 = 2.0 / 3.0;
float3 x0 = normal;
float3 shColorDiff = shCoeffs[0];
float3 shColor;
shColor  = shCoeffs[1].xyz * x0.y;
shColor += shCoeffs[2].xyz * x0.z;
shColor += shCoeffs[3].xyz * x0.x;
shColor *= kSH_A1;
shColorDiff += shColor;
color.rgb *= shColorDiff;
}
