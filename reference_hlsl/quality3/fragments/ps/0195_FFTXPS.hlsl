// Shader fragment  [PS slot 195]  FFTXPS

// ---- uniform parameters ----
uniform struct { float4 mParams; } FFTXInfo;   // reg-meta 028602860001000000000008

// ---- declarations / helper functions ----
extern uniform sampler Butterfly : register(s0);  
extern uniform sampler Source : register(s1);     
float4 fft2(float2 i, float2 w, float2 uv)
{
float4 input1 = tex2D(Source, float2(i.x, uv.y)).xyzw;
float4 input2 = tex2D(Source, float2(i.y, uv.y)).xyzw;
float res1x = w.x * input2.x - w.y * input2.y;
float res1y = w.y * input2.x + w.x * input2.y;
float res2x = w.x * input2.z - w.y * input2.w;
float res2y = w.y * input2.z + w.x * input2.w;
return input1 + float4(res1x, res1y, res2x, res2y);
}

// ---- fragment body (spliced into the generated main()) ----
const float FFT_SIZE = FFTXInfo.mParams.x;
const float _pass = FFTXInfo.mParams.y;
float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
 float halfPixOffset = 0.0;

float4 _data = tex2D(Butterfly, float2(uv.x, (_pass / FFT_SIZE) + halfPixOffset)).xyzw;
float2 i = _data.xy;
float2 w = _data.zw;
float4 result = fft2(i, w, uv);
Current.color = result;
