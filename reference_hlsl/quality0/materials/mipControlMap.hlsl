// Material shader: mipControlMap
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: copyPositionUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 samplerInfo0;
float decodeHeight(float4 h)
{
return h.x + h.y * 1.0/255.0;
}
float2 encodeHeight(float h)
{
return float2(floor(h * 255.0) * (1.0 / 255.0), frac(h * 255.0));
}

void main_pixel()
{
    // --- fragment: MipControlMapPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 tc_int = floor(In.texcoord<t0>.xy * samplerInfo0.xy);
    float2 tc = tc_int * samplerInfo0.zw;
    float4 s0 = tex2D(Sampler<s0>, tc + samplerInfo0.zw * float2(-1,-1));
    float4 s1 = tex2D(Sampler<s0>, tc + samplerInfo0.zw * float2(0,-1));
    float4 s2 = tex2D(Sampler<s0>, tc + samplerInfo0.zw * float2(-1,0));
    float4 s3 = tex2D(Sampler<s0>, tc + samplerInfo0.zw * float2(0,0));
    float4 bs = float4(s0.b, s1.b, s2.b, s3.b);
    float4 as = float4(s0.a, s1.a, s2.a, s3.a);
    float4 heights = float4(decodeHeight(s0), decodeHeight(s1), decodeHeight(s2), decodeHeight(s3));
    float4 capHeights = bs > 0 ? heights : 1;
    float  avgHeight = dot(heights, 1) * 0.25;
    float  minHeight = min(min(capHeights.x, capHeights.y), min(capHeights.z, capHeights.w));
    // take the lowest flattened height if any, otherwise the average
    float  height = any(bs) ? minHeight : avgHeight;
    Current.color = float4(encodeHeight(height), dot(bs,1), dot(as,1));
}
