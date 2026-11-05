// Material shader: blitCombineShader
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
sampler srcMap0 : register(s0);
sampler srcMap1 : register(s1);
sampler srcMap2 : register(s2);
sampler srcMap3 : register(s3);
sampler alphaMask : register(s4);

void main_pixel()
{
    // --- fragment: blitCombinePS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 uv = In.texcoord<t0>.xy;
    float4 texels = float4(
    tex2D(srcMap0, uv).x,
    tex2D(srcMap1, uv).x,
    tex2D(srcMap2, uv).x,
    tex2D(srcMap3, uv).x);
    float4 mask;
    mask = tex2D(alphaMask, uv).aaaa;
    mask = sign(saturate(mask));
    texels = saturate(texels - (mask * blitInfo.mXYWH));
    texels *= blitInfo.mScaleAndBias.xxxx;
    texels += blitInfo.mScaleAndBias.yyyy;
    Current.color = texels;
}
