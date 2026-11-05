// Material shader: rgbCubeShader
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
// PIXEL SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler      screenSampler   : register( s0 );
extern uniform sampler      cubeSampler     : register( s1 );
uniform float4x4 colorMatrix;
extern uniform sampler      screenSampler   : register( s0 );

void main_pixel()
{
    // --- fragment: rgbCubePF   (cond 0d00010000000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    float4 clut                 = tex3D( cubeSampler, color.rgb );
    Current.color.rgb           = clut.rgb;
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
    // --- fragment: rgbColorGradePF   (cond 0000000000000000000000000000000000000100000001ff)
    float2 uv                   = In.texcoord0.xy;
    float4 color                = tex2D( screenSampler, uv );
    Current.color.rgb           = float3( dot( colorMatrix[0], color.rgb ), dot( colorMatrix[1], color.rgb ), dot( colorMatrix[2], color.rgb ) );
    Current.color.a             = sqrt(dot(Current.color.rgb, float3(0.299, 0.587, 0.114))); // compute luma;
}
