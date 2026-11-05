// Material shader: CircleShaderZoomFade
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: colorT2SetupVS   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0>.xy = In.texcoord0.xy;
    Current.color = In.color;
    // --- fragment: toClipSpace   (cond 0000000000000000000000000000000000000000000000ff)
    float4 worldPosition = float4(mul(Current.position, modelToWorld), 1);
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (4 fragments; each may be conditionally enabled)
//==============================================================================
sampler inputTexture : register(s0);
uniform struct { float4 baseColor; float4 fadeInfo; } globalDataView;

void main_pixel()
{
    // --- fragment: colorT2SetupPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 color = In.color;
    float2 uv = In.texcoord0.xy;
    // --- fragment: CircleTexturePS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texColor = tex2Dlod(inputTexture, float4(uv,0,0));
    // Alpha reject
    clip(texColor.a - 0.1f);
    Current.color = texColor * color;
    Current.color.a = color.a;
    // --- fragment: zoomFade   (cond 0000000000000000000000000000000000000000000000ff)
    float zoomBlend = globalDataView.fadeInfo.y * color.a;
    Current.color = float4(color.r, color.g, color.b, zoomBlend);
    // --- fragment: HDRToneMap   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb = pow(In.color.rgb, float3(2.2, 2.2, 2.2));
}
