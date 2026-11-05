// Material shader: copyControlMapToHeightMap
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
uniform float4 samplerInfo14;
sampler controlMapSampler : register(s14);

void main_pixel()
{
    // --- fragment: copyControlMapToHeightMap   (cond 0000000000000000000000000000000000000000000000ff)
    float4 controlMap = tex2D(controlMapSampler, In.texcoord<t0>.xy).xyzw;
    float height = controlMap.x + controlMap.y / 255.0;  
    height -= controlMap.w / 2048.0;  
    float final = height;
    Current.color.rgba = float4(final, 0,0,0);
}
