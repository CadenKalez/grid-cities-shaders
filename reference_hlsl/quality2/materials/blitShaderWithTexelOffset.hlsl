// Material shader: blitShaderWithTexelOffset
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
uniform struct { float4 mParams; } shaderDataTerrainInfo;
sampler srcMap : register(s0);

void main_pixel()
{
    // --- fragment: blitPSWithOffset   (cond 0000000000000000000000000000000000000000000000ff)
    const float textureWidth = shaderDataTerrainInfo.mParams.x;
    const float textureHeight = shaderDataTerrainInfo.mParams.y;
    float2 uv = In.texcoord<t0>.xy;
    float4 pixel = tex2D(srcMap, uv).rgba;
    Current.color = pixel;
}
