// Material shader: particleQuadUnified
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4x4 modelToClip;
uniform float4 worldCameraDirection;

void main_vertex()
{
    // --- fragment: particleQuadUnifiedVS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 tiles = Current.color1.xyzw * 255;
    int corner = 0;
    int cx = corner % 2;
    int cy = corner / 2;
    tiles += float4(cx, 1 - cy, cx, 1 - cy);
    float2 uv0 = Current.texcoord0 * tiles.xy;
    float2 uv1 = Current.texcoord0 * tiles.zw;
    Current.position = mul(float4(Current.position, 1), modelToClip);
    Current.texcoord0 = uv0;
    Current.texcoord1 = uv1;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
sampler diffuse;

void main_pixel()
{
    // --- fragment: particleQuadUnifiedPS   (cond 0000000000000000000000000000000000000000000000ff)
    float4 tileColor0 = tex2D(diffuse, Current.texcoord0);
    float4 tileColor1 = tex2D(diffuse, Current.texcoord1);
    fragOut.color *= lerp(tileColor0, tileColor1, Current.color1.y);
}
