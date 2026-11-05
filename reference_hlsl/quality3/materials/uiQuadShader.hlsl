// Material shader: uiQuadShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 cameraToClip;

void main_vertex()
{
    // --- fragment: copyPositionColorUV0   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0.xy;
    // --- fragment: viewToClip   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position = mul(In.position, cameraToClip);
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler2D uiTex : register(s0);

void main_pixel()
{
    // --- fragment: uiQuadPF   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(uiTex, In.texcoord<t0>.xy);
    clip (texColor.a - 0.1f);
    Current.color.rgb = texColor.rgb * texColor.a * In.color.a;
    Current.color.a = texColor.a * In.color.a;
}
