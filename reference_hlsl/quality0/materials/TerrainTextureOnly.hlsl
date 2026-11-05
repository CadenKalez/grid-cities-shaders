// Material shader: TerrainTextureOnly
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4x3 modelToWorld;

void main_vertex()
{
    // --- fragment: toClipSpaceCopyUV   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = In.texcoord0;
    float4 clipPosition = mul(Current.position, modelToClip);
    Current.position = clipPosition;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
extern uniform sampler textureMap : register(s0);

void main_pixel()
{
    // --- fragment: terrainTextureOnlyPSFragment   (cond 0000000000000000000000000000000000000000000000ff)
    //get uv texture coordinate from interpolators
    float2 uv = float2(In.texcoord<t0>.x, In.texcoord<t0>.y);
    //read texel value
    float texelValue = tex2D(textureMap, uv).r;
    //add the value from previously rendered RTT and the texture in brush via alpha blend operation in RT
    float finalValue=texelValue;
    Current.color = float4( finalValue, finalValue, finalValue, 1.0);
}
