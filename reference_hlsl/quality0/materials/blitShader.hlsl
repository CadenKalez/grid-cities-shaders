// Material shader: blitShader
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
sampler srcMap : register(s0);

void main_pixel()
{
    // --- fragment: blitPS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord<t0>.xy;
    float4 pixel = tex2D(srcMap, uv).rgba;
    pixel *= blitInfo.mScaleAndBias.xxxx;
    pixel += blitInfo.mScaleAndBias.yyyy;
    Current.color = pixel;
}
