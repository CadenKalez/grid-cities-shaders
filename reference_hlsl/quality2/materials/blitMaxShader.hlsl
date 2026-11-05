// Material shader: blitMaxShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: blitVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xyz = In.texcoord<t0>.xyz;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform struct { float4 mXYWH; float4 mScaleAndBias; } blitInfo;
uniform float4 samplerInfo0;
sampler srcMap : register(s0);

void main_pixel()
{
    // --- fragment: blitMaxPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord<t0>.xy;
    float2 st = samplerInfo0.zw * 0.5;  
    float4 sample0 = tex2D(srcMap, uv + float2(-st.x, -st.y)).xyzw;
    float4 sample1 = tex2D(srcMap, uv + float2(-st.x,  st.y)).xyzw;
    float4 sample2 = tex2D(srcMap, uv + float2( st.x, -st.y)).xyzw;
    float4 sample3 = tex2D(srcMap, uv + float2( st.x,  st.y)).xyzw;
    float4 maxval = max(sample0, sample1);
    maxval = max(maxval, sample2);
    maxval = max(maxval, sample3);
    Current.color = maxval;
}
