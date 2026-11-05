// Material shader: dofDownsampleSimpleShader
// Reassembled from fragment library. Fragments are spliced in order into one main();
// "Current" is the running vertex/pixel state, "In" the stage input, <tN> interpolator slots.

//==============================================================================
// VERTEX SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 screenInfo;
uniform float4x4 worldToClip;

void main_vertex()
{
    // --- fragment: dofDownsampleSimpleVS   (cond 0000000000000000000000000000000000000000000000ff)
    //Current.position = mul( float4(position,1), worldToClip );
    Current.texcoord<t0>.xy = In.texcoord0.xy + float2( -1.0, -1.0 ) * screenInfo.zw * 2.0f;
    Current.texcoord<t0>.zw = In.texcoord0.xy + float2( +1.0, -1.0 ) * screenInfo.zw * 2.0f;
    Current.texcoord<t1>.xy = In.texcoord0.xy + float2( -1.5, -1.5 ) * screenInfo.zw * 2.0f;
    Current.texcoord<t1>.zw = In.texcoord0.xy + float2( -0.5, -1.5 ) * screenInfo.zw * 2.0f;
    Current.texcoord<t2>.xy = In.texcoord0.xy + float2( +0.5, -1.5 ) * screenInfo.zw * 2.0f;
    Current.texcoord<t2>.zw = In.texcoord0.xy + float2( +1.5, -1.5 ) * screenInfo.zw * 2.0f;
}

//==============================================================================
// PIXEL SHADER  (1 fragments; each may be conditionally enabled)
//==============================================================================
uniform float4 screenInfo;
extern uniform sampler colorTex : register(s0);

void main_pixel()
{
    // --- fragment: dofDownsampleSimplePS   (cond 0000000000000000000000000000000000000000000000ff)
    float2 dofRowDelta = float2(0.0f,0.25f*screenInfo.w * 2.0f);
    float2 rowOfs[4];
    // "rowOfs" reduces how many moves PS2.0 uses to emulate swizzling.
    rowOfs[0] = float2(0, 0);
    rowOfs[1] = dofRowDelta.xy;
    rowOfs[2] = dofRowDelta.xy * 2;
    rowOfs[3] = dofRowDelta.xy * 3;
    // Use bilinear filtering to average 4 color samples for free.
    Current.color.rgba = float4(0, 0, 0, 0);
    Current.color.rgba += tex2D( colorTex, In.texcoord0.xy + rowOfs[0] ).rgba;
    Current.color.rgba += tex2D( colorTex, In.texcoord0.zw + rowOfs[0] ).rgba;
    Current.color.rgba += tex2D( colorTex, In.texcoord0.xy + rowOfs[2] ).rgba;
    Current.color.rgba += tex2D( colorTex, In.texcoord0.zw + rowOfs[2] ).rgba;
    Current.color.rgba /= 4;
}
