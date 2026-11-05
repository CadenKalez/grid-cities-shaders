// Material shader: ScreenEffectsTextureShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================

void main_vertex()
{
    // --- fragment: SimpleScreenQuadVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position = float4(In.position.xy,0,1);
    Current.texcoord<t0> = In.texcoord0.xy;
    Current.color = In.color;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler additionalTex : register(s0);

void main_pixel()
{
    // --- fragment: ScreenEffectsTextureShaderPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(additionalTex, In.texcoord<t0>.xy);
    Current.color.xyz = In.color.rgb * texColor.rgb;
    Current.color.w   = In.color.w * texColor.w;
}
