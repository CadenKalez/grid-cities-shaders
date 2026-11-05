// Shader fragment  [PS slot 194]  initFFTPS

// ---- uniform parameters ----
uniform struct { float4 mParams; float4 mInvGridSizes; } initFFTInfo;   // reg-meta 028402840002000000000008

// ---- declarations / helper functions ----
extern uniform sampler Spectrum12 : register(s0);
extern uniform sampler Spectrum34 : register(s1);
float2 getSpectrum(float k, float2 s0, float2 s0c, float t)
{
float w = sqrt(9.81 * k * (1.0 + k * k / (370.0 * 370.0)));  
float2 sc = float2(0,0);
sincos(w * t, sc.x, sc.y);  
return float2((s0.x + s0c.x) * sc.y - (s0.y + s0c.y) * sc.x, (s0.x - s0c.x) * sc.x + (s0.y - s0c.y) * sc.y);
}
float2 i(float2 z)
{
return float2(-z.y, z.x); 
}

// ---- fragment body (spliced into the generated main()) ----
const float FFT_SIZE = initFFTInfo.mParams.x;
const float t = initFFTInfo.mParams.y;
const float mrt = initFFTInfo.mParams.z;  
const float4 INVERSE_GRID_SIZES = initFFTInfo.mInvGridSizes;
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
float2 st = floor(uv * FFT_SIZE) / FFT_SIZE;
float x = uv.x > 0.5 ? st.x - 1.0 : st.x;
float y = uv.y > 0.5 ? st.y - 1.0 : st.y;
st = float2((1.0 + 0.5 / FFT_SIZE) - st);
float4 s12 = tex2D(Spectrum12, uv).xyzw;
float4 s34 = tex2D(Spectrum34, uv).xyzw;
float4 s12c = tex2D(Spectrum12, st).xyzw;
float4 s34c = tex2D(Spectrum34, st).xyzw;
float2 k1 = float2(x, y) * INVERSE_GRID_SIZES.x;
float2 k2 = float2(x, y) * INVERSE_GRID_SIZES.y;
float2 k3 = float2(x, y) * INVERSE_GRID_SIZES.z;
float2 k4 = float2(x, y) * INVERSE_GRID_SIZES.w;
float K1 = length(k1);  
float K2 = length(k2);
float K3 = length(k3);
float K4 = length(k4);
float IK1 = K1 == 0.0 ? 0.0 : 1.0 / K1;  
float IK2 = K2 == 0.0 ? 0.0 : 1.0 / K2;
float IK3 = K3 == 0.0 ? 0.0 : 1.0 / K3;
float IK4 = K4 == 0.0 ? 0.0 : 1.0 / K4;
float2 h1 = getSpectrum(K1, s12.xy, s12c.xy, t);  
float2 h2 = getSpectrum(K2, s12.zw, s12c.zw, t);
float2 h3 = getSpectrum(K3, s34.xy, s34c.xy, t);
float2 h4 = getSpectrum(K4, s34.zw, s34c.zw, t);
float4 height = float4(h1 + i(h2), h3 + i(h4));
float4 slope1 = float4(i(k1.x * h1) - k1.y * h1, i(k2.x * h2) - k2.y * h2);  
float4 slope2 = float4(i(k3.x * h3) - k3.y * h3, i(k4.x * h4) - k4.y * h4);
float4 choppy1 = slope1 * float4(IK1, IK1, IK2, IK2);  
float4 choppy2 = slope2 * float4(IK3, IK3, IK4, IK4);
if ( mrt>=4.0 )
{
Current.color.rgba = height;
Current.color1.rgba = slope1;
Current.color2.rgba = slope2;
Current.color3.rgba = choppy1;
}
else
{
Current.color.rgba = choppy2;
Current.color1.rgba = float4(0.0, 0.0, 0.0, 0.0);
Current.color2.rgba = float4(0.0, 0.0, 0.0, 0.0);
Current.color3.rgba = float4(0.0, 0.0, 0.0, 0.0);
}
