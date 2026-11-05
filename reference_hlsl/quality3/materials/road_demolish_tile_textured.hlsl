// Material shader: road_demolish_tile_textured
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 worldToClip;

void main_vertex()
{
    // --- fragment: worldToClipSpaceVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position = mul(float4(Current.position.xyz, 1), worldToClip);
    // --- fragment: copyVertexColor   (cond 0000000000000000000000000000000000000000000000ff)
    // --- fragment: copyUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler textureSampler : register(s0);

void main_pixel()
{
    // --- fragment: roadDemolishTileTexturedPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(textureSampler, In.texcoord0.xy);
    Current.color.rgb = (In.color.rgb * texColor.rgb) * texColor.a;
    Current.color.a = texColor.a;
}
