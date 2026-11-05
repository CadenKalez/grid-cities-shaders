// Material shader: cityBoundaryShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 worldToClip;
uniform float4 customParams[4];
sampler HeightMapVS : register(s0);

void main_vertex()
{
    // --- fragment: cityBoundaryVS   (cond 0000000000000000000000000000000000000000000000ff)
    // Total hack to compute top-down UV: we know the city box is limited to 2048x2048
    // so we just take our current xy positions (given in world space) and scale and
    // bias them to get UV coords
    float2 topDownUV = (Current.position.xy + 1024.0f) / 2048.0f;
    // Height is [0,1] so we need to unnormalize to get correct value
    float height = tex2Dlod(HeightMapVS, float4(topDownUV, 0, 0)).x;
    height *= 2048.0f;
    height -= 1024.0f;
    // Clamp to sea level
    height = max(height, customParams[0].y);
    // Slight bias to pass depth testing with terrain
    height += 2.5f;
    float4 worldPos = float4(Current.position.xy, height, 1);
    Current.position = mul(worldPos, worldToClip);
    Current.texcoord<t0> = In.texcoord0.xy;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 customParams[4];
sampler textureSampler : register(s0);

void main_pixel()
{
    // --- fragment: cityBoundaryPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2D(textureSampler, In.texcoord0.xy);
    // Adjust opacity
    Current.color = In.color * texColor * customParams[0].x;
    Current.color.a = texColor.a * customParams[0].x;
}
