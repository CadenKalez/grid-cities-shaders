// Material shader: MovieThreshold_3
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
uniform float4 screenInfo;
sampler movie;

void main_pixel()
{
    // --- fragment: MovieThresholdPS_3   (cond 0000000000000000000000000000000000000000000000ff)
    const float kLevels = (3);
    float4 halfSI = screenInfo * 0.5;  // tap width
    float4 sc0 = tex2D(movie, In.texcoord0.xy + float2(halfSI.z, 0));
    float4 sc1 = tex2D(movie, In.texcoord0.xy - float2(halfSI.z, 0));
    float4 sc2 = tex2D(movie, In.texcoord0.xy + float2(0, halfSI.w));
    float4 sc3 = tex2D(movie, In.texcoord0.xy - float2(0, halfSI.z));
    Current.color = 0.25 * (sc0 + sc1 + sc2 + sc3) * Current.color;
    float lum = (1 / kLevels) * round(kLevels * Current.color.g);
    Current.color.rgb = float3(lum, lum, lum);
}
