// Material shader: FFTYShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mParams; } FFTYInfo;
extern uniform sampler Butterfly : register(s0);  
extern uniform sampler Source : register(s1);     
float4 fft2(float2 i, float2 w, float2 uv)
{
float4 input1 = tex2D(Source, float2(uv.x, i.x)).xyzw;
float4 input2 = tex2D(Source, float2(uv.x, i.y)).xyzw;
float res1x = w.x * input2.x - w.y * input2.y;
float res1y = w.y * input2.x + w.x * input2.y;
float res2x = w.x * input2.z - w.y * input2.w;
float res2y = w.y * input2.z + w.x * input2.w;
return input1 + float4(res1x, res1y, res2x, res2y);
}

void main_pixel()
{
    // --- fragment: FFTYPS   (cond 0000000000000000000000000000000000000000000000ff)
    const float FFT_SIZE = FFTYInfo.mParams.x;
    const float _pass = FFTYInfo.mParams.y;
    float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
     float halfPixOffset = 0.0;
    
    float4 _data = tex2D(Butterfly, float2(uv.y, (_pass / FFT_SIZE) + halfPixOffset)).xyzw;
    float2 i = _data.xy;
    float2 w = _data.zw;
    float4 result = fft2(i, w, uv);
    Current.color = result;
}
