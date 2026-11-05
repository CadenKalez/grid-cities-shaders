// Material shader: decalFloatQuad
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (2 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 SkinBones[(192)];
uniform float4x4 worldToClip;

void main_vertex()
{
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    int xformIdx = toInt(Current.indices.x);
    float3x4 modelToWorld = float3x4(SkinBones[xformIdx + 0], SkinBones[xformIdx + 1], SkinBones[xformIdx + 2]);
    float3x4 modelToTexture = float3x4(In.texcoord1, In.texcoord2, In.texcoord3);
    float3 modelPos = Current.position.xyz;
    float3 worldPos = mul(modelToWorld, float4(modelPos,1));
    Current.position = mul(float4(worldPos,1), worldToClip);
    Current.texcoord<t0> = In.texcoord0;
    // --- fragment: decalFloatQuad   (cond 0000000000000000000000000000000000000000000000ff)
    Current.texcoord<t0> = mul(modelToTexture, float4(modelPos,1));
}

//==============================================================================
// PIXEL SHADER  (3 fragments; each may be conditionally enabled)
//==============================================================================

void main_pixel()
{
    // --- fragment: decalBase   (cond 0000000000000000000000000000000000000000000000ff)
    float4 texXform = In.texcoord<t0>;
    // --- fragment: decalFloatQuad   (cond 0000000000000000000000000000000000000000000000ff)
    float3 textureFloatPosition = In.texcoord<t0>.xyz;
    clip(-textureFloatPosition.z);
    float2 uvOrig = textureFloatPosition.xy * -0.5 + 0.5;
    float2 uv = uvOrig * texXform.xy + texXform.zw;
    float4 decalTexture = tex2D(Sampler<s0>, uv);
    Current.color = decalTexture;
    //Current.color.a = 1;
    // --- fragment: decalNeonBrighten   (cond 0000000000000000000000000000000000000000000000ff)
    Current.color.rgb *= 2;
}
