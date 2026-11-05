// Material shader: MovieBW
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 materialColor;
uniform float4 screenInfo;

void main_vertex()
{
    // --- fragment: MovieVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.position.xy *= screenInfo.zw;
    Current.position.xy -= float2(0.5, 0.5);
    Current.position.xy *= float2(2, -2);
    Current.color = materialColor;
    Current.texcoord0 = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler movie;

void main_pixel()
{
    // --- fragment: MovieBWPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 sourceColor = tex2D(movie, In.texcoord0.xy);
    Current.color = sourceColor * Current.color;
    float lum = dot(Current.color.rgb, float3(0.333, 0.333, 0.333));
    Current.color.rgb = float3(lum, lum, lum);
}
